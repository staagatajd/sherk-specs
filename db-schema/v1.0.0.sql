-- SHERK MVP baseline for Supabase PostgreSQL 15+. Run as the project database owner.
-- All client traffic passes through sherk-api. Only the backend holds service_role.
-- auth.users supplies identity; account.uuid is the authenticated user's UUID.
-- Client-generated UUIDs and timestamps are accepted on sync. The API stamps actors.
BEGIN;

DO $$ BEGIN
  CREATE TYPE public.market_role AS ENUM ('contributor', 'moderator', 'administrator', 'system_administrator');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.market_category_kind AS ENUM ('conditioned', 'food', 'other');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.market_condition AS ENUM ('new', 'preloved');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.market_listing_status AS ENUM ('available', 'reserved', 'sold', 'withdrawn', 'removed');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.market_report_decision AS ENUM ('dismissed', 'removed_listing', 'referred_account');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS public.market_account (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE,
  display_name text NOT NULL CHECK (btrim(display_name) <> ''),
  role public.market_role NOT NULL DEFAULT 'contributor',
  suspended_at timestamptz,
  suspended_by uuid,
  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  CHECK ((suspended_at IS NULL) = (suspended_by IS NULL))
);

CREATE TABLE IF NOT EXISTS public.market_admission (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE,
  -- Exactly one grant per row. The API normalizes verified Google identities at admission.
  domain text CHECK (domain = lower(btrim(domain)) AND domain <> '' AND domain !~ '[@[:space:]]'),
  seller_email text CHECK (seller_email = lower(btrim(seller_email)) AND seller_email ~ '^[^@[:space:]]+@[^@[:space:]]+$'),
  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  CHECK (num_nonnulls(domain, seller_email) = 1)
);

CREATE TABLE IF NOT EXISTS public.market_setting (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE,
  name text NOT NULL CHECK (btrim(name) <> ''),
  value jsonb NOT NULL,
  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);

CREATE TABLE IF NOT EXISTS public.market_category (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE,
  name text NOT NULL CHECK (btrim(name) <> ''),
  kind public.market_category_kind NOT NULL,
  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);

CREATE TABLE IF NOT EXISTS public.market_listing (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE,
  seller_uuid uuid NOT NULL,
  category_uuid uuid NOT NULL,
  title text NOT NULL CHECK (btrim(title) <> ''),
  description text NOT NULL CHECK (btrim(description) <> ''),
  price_php numeric(12,2) NOT NULL CHECK (price_php >= 0 AND price_php <> 'NaN'::numeric),
  condition public.market_condition,
  pickup_area text NOT NULL CHECK (btrim(pickup_area) <> ''),
  -- Ordered private Storage object keys, delivered through the API according to visibility.
  photo_keys text[] NOT NULL,
  portion text CHECK (btrim(portion) <> ''),
  last_pickup_date date,
  rules_confirmed_at timestamptz NOT NULL,
  published_at timestamptz NOT NULL DEFAULT now(),
  confirmed_available_at timestamptz,
  status public.market_listing_status NOT NULL DEFAULT 'available',
  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  CHECK (seller_uuid = created_by),
  CHECK (cardinality(photo_keys) > 0 AND array_ndims(photo_keys) = 1
         AND array_position(photo_keys, NULL) IS NULL AND array_to_string(photo_keys, chr(31)) !~ ('(^|' || chr(31) || ')[[:space:]]*(' || chr(31) || '|$)')),
  CHECK ((portion IS NULL) = (last_pickup_date IS NULL)),
  CHECK (confirmed_available_at IS NULL OR confirmed_available_at >= published_at)
);

CREATE TABLE IF NOT EXISTS public.market_thread (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE,
  listing_uuid uuid NOT NULL,
  buyer_uuid uuid NOT NULL,
  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  CHECK (buyer_uuid = created_by)
);

CREATE TABLE IF NOT EXISTS public.market_message (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE,
  thread_uuid uuid NOT NULL,
  body text NOT NULL CHECK (btrim(body) <> ''),
  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);

CREATE TABLE IF NOT EXISTS public.market_report (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE,
  -- A conduct report cites a message; the API derives the reported member from its author.
  listing_uuid uuid,
  message_uuid uuid,
  reason text NOT NULL CHECK (btrim(reason) <> ''),
  -- API copies only the cited material so moderation survives later edits and removal.
  evidence jsonb NOT NULL CHECK (jsonb_typeof(evidence) = 'object'),
  decision public.market_report_decision,
  decision_reason text CHECK (btrim(decision_reason) <> ''),
  decided_at timestamptz,
  decided_by uuid,
  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  CHECK (num_nonnulls(listing_uuid, message_uuid) = 1),
  CHECK (num_nonnulls(decision, decision_reason, decided_at, decided_by) IN (0, 4))
);

CREATE UNIQUE INDEX IF NOT EXISTS market_admission_domain ON public.market_admission (domain) WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS market_admission_email ON public.market_admission (seller_email) WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS market_setting_name ON public.market_setting (name) WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS market_category_name ON public.market_category (lower(btrim(name))) WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS market_thread_pair ON public.market_thread (listing_uuid, buyer_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS market_thread_buyer ON public.market_thread (buyer_uuid, updated_at);
CREATE INDEX IF NOT EXISTS market_listing_seller ON public.market_listing (seller_uuid, updated_at);
CREATE INDEX IF NOT EXISTS market_listing_category ON public.market_listing (category_uuid, published_at DESC);
CREATE INDEX IF NOT EXISTS market_listing_recent ON public.market_listing (published_at DESC) WHERE archived_at IS NULL AND status = 'available';
CREATE INDEX IF NOT EXISTS market_listing_keywords ON public.market_listing USING gin (to_tsvector('simple', title || ' ' || description));
CREATE INDEX IF NOT EXISTS market_message_thread ON public.market_message (thread_uuid, created_at, uuid);
CREATE INDEX IF NOT EXISTS market_report_listing ON public.market_report (listing_uuid);
CREATE INDEX IF NOT EXISTS market_report_message ON public.market_report (message_uuid);
CREATE INDEX IF NOT EXISTS market_report_pending ON public.market_report (created_at) WHERE decision IS NULL AND archived_at IS NULL;

-- Internal current state. Missing parents, suspension and incomplete category data fail closed.
-- Use an absolute 720-hour window and a Philippine civil-date cutoff, independently of session timezone.
CREATE OR REPLACE VIEW public.market_listing_state WITH (security_invoker = true) AS
SELECT l.uuid, l.seller_uuid, l.category_uuid,
       CASE WHEN l.archived_at IS NOT NULL OR l.status = 'removed' THEN 'removed'
            WHEN a.uuid IS NULL OR a.suspended_at IS NOT NULL OR c.uuid IS NULL THEN 'unavailable'
            WHEN l.status IN ('withdrawn','sold') THEN l.status::text
            WHEN c.kind = 'food' AND l.last_pickup_date IS NULL THEN 'unavailable'
            WHEN c.kind = 'conditioned' AND l.condition IS NULL THEN 'unavailable'
            WHEN now() >= coalesce(l.confirmed_available_at, l.published_at) + interval '720 hours'
              OR (c.kind = 'food' AND l.last_pickup_date < (now() AT TIME ZONE 'Asia/Manila')::date)
              THEN 'expired'
            ELSE l.status::text END AS state
FROM public.market_listing l
LEFT JOIN public.market_account a ON a.uuid = l.seller_uuid AND a.archived_at IS NULL
LEFT JOIN public.market_category c ON c.uuid = l.category_uuid AND c.archived_at IS NULL;

-- API projection for guest search and direct links. Seller identity is added separately for members.
CREATE OR REPLACE VIEW public.market_catalog WITH (security_invoker = true) AS
SELECT l.uuid, l.title, l.description, l.price_php, l.category_uuid, c.name AS category_name,
       l.condition, l.pickup_area, l.photo_keys, l.portion, l.last_pickup_date, l.published_at, s.state
FROM public.market_listing_state s
JOIN public.market_listing l ON l.uuid = s.uuid
JOIN public.market_category c ON c.uuid = l.category_uuid
WHERE s.state = 'available';

-- Privileged API calls must derive the buyer/sender UUID from the verified session.
-- Lock the records controlling availability before evaluating the state under READ COMMITTED.
CREATE OR REPLACE FUNCTION public.market_lock_offer(p_listing uuid, p_actor uuid)
RETURNS text LANGUAGE plpgsql SET search_path = '' AS $$
DECLARE
  offer public.market_listing%ROWTYPE;
BEGIN
  SELECT * INTO STRICT offer FROM public.market_listing WHERE uuid = p_listing FOR SHARE;
  PERFORM 1 FROM public.market_account WHERE uuid IN (p_actor, offer.seller_uuid) ORDER BY uuid FOR SHARE;
  IF NOT EXISTS (SELECT FROM public.market_account WHERE uuid = p_actor AND archived_at IS NULL AND suspended_at IS NULL) THEN
    RAISE EXCEPTION 'Active membership required';
  END IF;
  PERFORM 1 FROM public.market_category WHERE uuid = offer.category_uuid FOR SHARE;
  RETURN (SELECT state FROM public.market_listing_state WHERE uuid = p_listing);
END $$;

CREATE OR REPLACE FUNCTION public.market_open_thread(p_uuid uuid, p_listing uuid, p_buyer uuid)
RETURNS uuid LANGUAGE plpgsql SET search_path = '' AS $$
DECLARE
  offer_state text;
  existing uuid;
BEGIN
  offer_state := public.market_lock_offer(p_listing, p_buyer);
  SELECT uuid INTO existing FROM public.market_thread
    WHERE listing_uuid = p_listing AND buyer_uuid = p_buyer AND archived_at IS NULL;
  IF FOUND THEN RETURN existing; END IF;
  IF offer_state IS DISTINCT FROM 'available' OR EXISTS
    (SELECT FROM public.market_listing WHERE uuid = p_listing AND seller_uuid = p_buyer) THEN
    RAISE EXCEPTION 'Listing does not accept new inquiries';
  END IF;
  INSERT INTO public.market_thread (uuid, listing_uuid, buyer_uuid, created_by)
    VALUES (p_uuid, p_listing, p_buyer, p_buyer)
    ON CONFLICT (listing_uuid, buyer_uuid) WHERE archived_at IS NULL DO NOTHING;
  SELECT uuid INTO STRICT existing FROM public.market_thread
    WHERE listing_uuid = p_listing AND buyer_uuid = p_buyer AND archived_at IS NULL;
  RETURN existing;
END $$;

CREATE OR REPLACE FUNCTION public.market_send_message(
  p_uuid uuid, p_thread uuid, p_sender uuid, p_body text, p_created_at timestamptz
) RETURNS uuid LANGUAGE plpgsql SET search_path = '' AS $$
DECLARE
  conversation public.market_thread%ROWTYPE;
  offer_state text;
  original public.market_message%ROWTYPE;
BEGIN
  SELECT * INTO STRICT conversation FROM public.market_thread
    WHERE uuid = p_thread AND archived_at IS NULL FOR SHARE;
  offer_state := public.market_lock_offer(conversation.listing_uuid, p_sender);
  IF p_sender <> conversation.buyer_uuid AND NOT EXISTS
    (SELECT FROM public.market_listing WHERE uuid = conversation.listing_uuid AND seller_uuid = p_sender) THEN
    RAISE EXCEPTION 'Thread participant required';
  END IF;
  -- Acknowledge a delivered message even when a retry arrives after the sale.
  SELECT * INTO original FROM public.market_message WHERE uuid = p_uuid;
  IF NOT FOUND THEN
    IF offer_state NOT IN ('available','reserved') OR offer_state IS NULL THEN
      RAISE EXCEPTION 'Conversation is closed';
    END IF;
    INSERT INTO public.market_message (uuid, thread_uuid, body, created_by, created_at, updated_at)
      VALUES (p_uuid, p_thread, p_body, p_sender, p_created_at, p_created_at)
      ON CONFLICT (uuid) DO NOTHING;
    SELECT * INTO STRICT original FROM public.market_message WHERE uuid = p_uuid;
  END IF;
  IF original.thread_uuid <> p_thread OR original.created_by <> p_sender OR original.body IS DISTINCT FROM p_body THEN
    RAISE EXCEPTION 'Message UUID already used';
  END IF;
  RETURN p_uuid;
END $$;

-- Lock down only objects owned by this baseline, including Supabase default API grants.
ALTER TABLE public.market_account ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_admission ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_setting ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_category ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_listing ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_thread ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_message ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_report ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE
  public.market_account,
  public.market_admission,
  public.market_setting,
  public.market_category,
  public.market_listing,
  public.market_thread,
  public.market_message,
  public.market_report,
  public.market_listing_state,
  public.market_catalog
FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
  public.market_account,
  public.market_admission,
  public.market_setting,
  public.market_category,
  public.market_listing,
  public.market_thread,
  public.market_message,
  public.market_report
TO service_role;
GRANT SELECT ON public.market_listing_state, public.market_catalog TO service_role;
REVOKE ALL ON FUNCTION public.market_lock_offer(uuid, uuid),
  public.market_open_thread(uuid, uuid, uuid),
  public.market_send_message(uuid, uuid, uuid, text, timestamptz) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.market_lock_offer(uuid, uuid),
  public.market_open_thread(uuid, uuid, uuid),
  public.market_send_message(uuid, uuid, uuid, text, timestamptz) TO service_role;

COMMIT;
