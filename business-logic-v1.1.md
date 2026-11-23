# SHERK business logic v1.1

## Project details and positioning

SHERK is Far Far Away’s mobile-friendly Next.js marketplace for the Visayas State University (VSU) community. A buyer can find an available item on campus, see its price and pickup area, and contact its seller from the listing. Sellers keep one listing current as an item becomes reserved, available again, or sold. This gives campus buyers a searchable alternative to following up on scattered buy-and-sell posts.

The MVP covers physical goods for campus pickup, including textbooks, school supplies, clothing, gadgets, and food. Students, faculty, university personnel, and authorized campus sellers use the same marketplace. Buyers and sellers arrange pickup and payment themselves. Services, payment processing, shipping, and delivery are outside the MVP.

## MVP features and system requirements

| Feature | Launch requirement |
| --- | --- |
| Campus membership | Use Google Sign-In and admit a user with a verified email on a VSU-approved domain. For an authorized campus seller outside those domains, an administrator confirms eligibility with the campus contact and approves the exact verified email. Other users retain guest access. Members can set and edit their display name. |
| Publish an offer | Each listing covers one offer. Require a title, description, category, PHP price, at least one photo, and a general campus pickup area. Require new or preloved condition where applicable. For food, require the portion covered by the price and the last pickup date. The seller can edit or withdraw their own listing. |
| Find an item | Show available listings newest first. Support keyword search and filters for category, price, condition, and listing date. Guests can see item details, photos, price, availability, and pickup area. Eligible members can also see the seller’s display name. |
| Arrange pickup | Selecting contact as a guest opens sign-in and returns an eligible member to the item. An eligible buyer can start one private text thread per listing with its seller. Either participant can reopen the thread from their inbox and see the listing’s current status. The seller updates availability as the exchange progresses. |
| Resolve abuse | A member can report a listing or another member’s conduct, giving a reason and identifying the relevant listing or message. A moderator records the decision and reason, dismisses an unfounded report, removes a violating listing, or refers account restrictions to an administrator. |

## User levels and access

| Role | Responsibility |
| --- | --- |
| A. System administrator | Manage technical configuration and access controls, monitor service health, schedule database backups, and verify recovery. |
| B. Administrator | Manage marketplace settings, categories, and user access. Approve eligible sellers, review reports, and suspend or reinstate accounts. Suspension hides the account’s listings and disables its posting and messaging. |
| C. Moderator | Review reported content, resolve reports, and remove violating listings. |
| D. Contributor (campus member) | Manage their own profile and listings, participate in their own buyer-seller conversations, and submit reports. Staff who trade follow the same eligibility and ownership rules. |
| E. Guest | Browse public listings, search, filter, and sign in to request contact with a seller. |

## Required solution layers

### Security and privacy by design

Enforce eligibility, role permissions, listing ownership, and thread access on the server. Only participants can open a conversation. Staff reviewing a report can inspect the specific content submitted with it. Keep sign-in emails private. Publish only a general campus pickup area and let participants agree on the exact meeting point in their thread.

Collect only the personal information needed to operate the marketplace. Prohibit commercial sale or sharing of personal data without an appropriate legal basis and consent. Before registration opens, publish the privacy notice and a contact for correction and deletion requests. The launch owner must approve and apply retention and deletion periods for accounts, listings, messages, reports, and backups as part of meeting the Philippine Data Privacy Act of 2012 (RA 10173) requirement.

### Marketplace safety

Show permitted goods and prohibited-item rules before publication and require sellers to confirm their offer follows them. At first contact, encourage participants to meet in a public campus area and inspect the item before paying. Removing a violating listing hides its content from search and direct links and closes its threads to new messages.

### Content and listing management

| Listing state | Discovery and inquiries | Seller action |
| --- | --- | --- |
| Available | Appears in search and accepts buyer inquiries. | Reserve after agreeing on pickup, mark sold after handoff, or withdraw. |
| Reserved | Leaves search. Existing threads stay open for pickup coordination. New buyers cannot start a thread, including from an old link. | Return to available if pickup falls through, mark sold, or withdraw. |
| Sold, withdrawn, or expired | Leaves search and closes all threads to new messages. Participants can see the outcome in their inbox. | No further action is needed. |

Expire an active listing 30 days after publication or the seller’s latest explicit confirmation of availability. For food, expire it at the earlier of that deadline and the end of the last pickup date in Philippine time. Recheck availability when a buyer starts an inquiry so a stale search result cannot open a thread on an unavailable item.

## Launch checks and pilot evidence

- On a phone, a guest finds a textbook by category and price, signs in, returns to the item, and contacts the seller. Verify the approved-domain and individually approved seller paths, and verify that an ineligible account retains guest access.
- Reserve the textbook, reopen it after a missed pickup, and mark it sold after handoff. Check search, old links, new inquiries, and existing threads at each step. Verify both the 30-day expiry and an earlier food pickup deadline.
- Report a prohibited listing and a specific abusive message. Verify the moderator can inspect the reported material, record a decision, and remove the listing. Verify a contributor cannot read another buyer’s thread or remove another member’s listing.
- Before launch, confirm the approved domains and seller authorization contact with VSU, assign a report reviewer, verify monitoring, and restore a scheduled backup.

During the pilot, count listings that receive a buyer inquiry within seven days of publication and listings that sellers mark sold. The first count measures contact with sellers. The second records seller-reported exchanges. Use existing listing and thread records for both.
