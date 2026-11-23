# SHERK business logic v1.1 proposal

## Project details and positioning

Far Far Away proposes SHERK, a mobile-friendly Next.js marketplace for the Visayas State University (VSU) community. Its promise to a buyer is simple: find an item available on campus today and reach the member selling it. A seller posts once and can take the item out of search as soon as someone claims it. This addresses two frustrations with scattered buy-and-sell posts: finding the item again and finding out whether it is still available.

The first release covers physical goods for campus pickup, including preloved textbooks, clothing, gadgets, school supplies, and food. Students, faculty, university personnel, and authorized campus sellers use the same listing and inquiry flow. Buyers and sellers arrange the exchange and payment themselves. Services, platform payments, shipping, and delivery are outside the proposed launch scope.

## System requirements and gaps in v1.0

| MVP feature | Gap in v1.0 | Proposed launch rule |
| --- | --- | --- |
| 1. Campus membership | Google Sign-In identifies an account but does not establish eligibility. | Admit accounts with a verified Google email on a VSU-approved domain. For authorized campus sellers outside those domains, an administrator confirms eligibility with the campus contact and approves the exact verified email. Everyone else retains guest access. Members choose a display name. |
| 2. Publish a listing | The fields are listed, but the minimum usable offer and the meaning of condition for food are unclear. | Require a title, description, category, PHP price, at least one photo, and a general campus pickup area. Require new or preloved condition where applicable. For food, state the portion covered by the price and the last pickup date. The seller can edit or withdraw their own offer. |
| 3. Find an available item | Search has filters but no default result set or guest visibility rule. | Show available items newest first. Support keyword search and filters for category, price, condition, and listing date. Guests can see item details, price, status, photo, and general pickup area. Sign-in unlocks the seller’s display name and contact through the app. |
| 4. Inquire and arrange pickup | Messaging and statuses are named without specifying how an inquiry ends. | From an available item, a member can start one private text thread with its seller and reopen it from an inbox. Both see the item and its current status. The seller can reserve it after agreeing on pickup, return it to available if plans change, or mark it sold after handoff. |
| 5. Report and resolve abuse | The access table groups reporting, moderation, and account management together. | A member can report a listing or another member’s conduct with a reason and the relevant listing or message. A moderator records a decision to dismiss the report or remove the listing and refers account restrictions to an administrator. |

## User levels and access

| Role | Responsibility |
| --- | --- |
| E. Guest | Browse and search public listings. Selecting contact prompts sign-in and returns an eligible member to the item. |
| D. Contributor | Browse, manage their own profile and listings, use their own conversations, and submit reports. |
| C. Moderator | Review reports, inspect the reported content, remove violating listings, and record the reason. |
| B. Administrator | Exercise moderation powers, approve eligible sellers, suspend or reinstate accounts, and maintain categories and marketplace settings. Suspension hides the account’s listings and disables posting and messaging. |
| A. System administrator | Manage technical configuration, access controls, service monitoring, backups, and recovery. Staff who trade follow the same eligibility and ownership rules as contributors. |

## Required solution layers

### Security and privacy by design

Enforce role, listing ownership, and conversation access on the server. Limit routine conversation access to its participants and moderator review to the content submitted with a report. Keep sign-in email private. Use broad pickup areas on listings and let participants agree on the meeting point in their thread.

Before opening registration, the administrator publishes a privacy notice and a contact for correction and deletion requests. The launch owner approves retention and deletion periods for accounts, listings, messages, reports, and backups against v1.0’s Philippine Data Privacy Act requirement.

### Marketplace safety

Show permitted goods and prohibited-item rules before publication. Require sellers to confirm their listing follows those rules. At first contact, encourage both parties to meet in a public campus area and inspect the item before paying. A moderator’s removal takes effect on search and direct listing links and prevents further inquiries.

### Content and listing management

Each listing represents one offer. Reserving it removes it from discovery and stops new inquiries while existing participants can still coordinate pickup. Sold and withdrawn listings close their threads to new messages. Expire an offer after 30 days unless the seller reconfirms availability, or at the end of the stated pickup date for food, whichever comes first. Expiry removes the offer from discovery and closes inquiries. The 30-day window is a proposed pilot default.

## Launch checks and pilot evidence

- On a phone, a guest finds a preloved textbook by category and price, signs in with an eligible account, and returns to message its seller. An ineligible account can browse but cannot send the message.
- The seller replies, reserves the book, and reopens it after a missed pickup. A second buyer finds it, arranges pickup, and the seller marks it sold. Verify the search results and thread permissions at each step, including when a buyer opens an old link.
- A member reports a prohibited item. A moderator can resolve the report and remove the item. A contributor cannot remove someone else’s listing or read another buyer’s conversation. An expired food listing disappears when its pickup date passes.
- Before launch, confirm the approved domains and seller authorization contact with VSU, name the report reviewer, and have the system administrator verify service monitoring and restore a scheduled backup.

During the pilot, use aggregate counts of listings that receive a buyer inquiry within seven days and listings that sellers mark sold. The first shows whether buyers reach sellers. The second is a seller-reported signal of campus exchanges. Both can be reviewed from existing listing and thread records.
