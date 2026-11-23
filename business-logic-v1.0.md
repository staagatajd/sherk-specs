# Business Logic

> Development of a Web-based Campus Buy-and-Sell Marketplace using Next.js for the Visayas State University Community

## Project Details

- **Company/Startup/Team Name:** Far Far Away
- **Project Code Name:** sherk
- **Project Short Code:** SHRK
- **Short Description:** A centralized campus marketplace that allows members of the VSU community to buy, sell, and discover locally available products, including preloved items, food, gadgets, and school supplies.
- **Long Description:** SHERK is a web-based campus buy-and-sell marketplace designed for the Visayas State University community. It provides a centralized platform where students, faculty members, university personnel, and authorized campus-based sellers can post products, browse available listings, and communicate with potential buyers. Unlike scattered Facebook buy-and-sell posts, the platform organizes products into searchable categories with filtering options, seller information, product descriptions, prices, and listing statuses. Users can communicate directly with sellers and arrange face-to-face transactions within the campus. The platform aims to make buying and selling within the VSU community more accessible, organized, and convenient.

## User Levels

| User Level | Description |
|---|---|
| A. System Administrator | Maintains the platform infrastructure, manages system configurations, oversees technical operations, and performs regular database backups. |
| B. Administrator | Manages general platform settings, user accounts, product categories, and system analytics and reports. |
| C. Moderator | Reviews reported listings and user activities, handles inappropriate content, and enforces marketplace guidelines. |
| D. Contributor (Campus Member) | Registered VSU community members who can browse, post, edit, and manage product listings, communicate with buyers or sellers, and report suspicious activities. |
| E. Guest | Users who do not log in but can browse limited public product listings and view basic product information. |

## System Requirements

1. The app shall allow eligible users to authenticate using Google Sign-In integration.

2. The app shall allow authenticated campus members to create and manage their marketplace profiles and display their basic seller information.

3. The app shall allow registered users to create, edit, and manage product listings by providing product names, descriptions, prices, categories, conditions, and product images.

4. The app shall allow users to browse, search, and filter available product listings based on keywords, categories, price ranges, product conditions, and listing dates.

5. The app shall allow buyers and sellers to communicate through an in-platform messaging feature and allow sellers to update listing statuses to Available, Reserved, or Sold.

6. The app shall allow users to report suspicious listings or inappropriate user activities, while moderators and administrators can review reports and take appropriate moderation actions.

7. The app shall provide administrative functions for managing platform configurations, user access, product categories, and system monitoring, including regular database backups.

## Required Solution Layers

1. **Security and Privacy by Design**
   - Comply with the Philippine Data Privacy Act of 2012 (RA 10173).
   - Restrict marketplace participation to eligible VSU community members.
   - Apply role-based access control to protect administrative and moderation functions.
   - Protect personal information and avoid publicly exposing sensitive user details.
   - Display general campus meeting locations instead of tracking users' precise real-time locations.
   - Apply appropriate data retention policies for inactive listings, messages, and user information.
   - Avoid unnecessary collection and storage of personal information.
   - Do not sell or share personal user data for commercial purposes without appropriate legal basis and consent.

2. **Marketplace Safety**
   - Provide reporting mechanisms for suspicious listings and inappropriate activities.
   - Allow moderators to review and remove listings that violate marketplace guidelines.
   - Display listing statuses to reduce confusion about product availability.
   - Encourage buyers and sellers to arrange transactions responsibly within the campus.

3. **Content and Listing Management**
   - Organize product listings into appropriate categories.
   - Allow sellers to update listing information and availability.
   - Automatically hide expired or outdated listings based on the platform's retention policy.
   - Prevent inappropriate or prohibited products from being listed.

## MVP Features and Access

> See the User Levels table for reference.

| Feature | Access |
|---|---|
| 1. Browse and view public product listings | A, B, C, D, E |
| 2. Google Sign-In and account management | A, B, C, D |
| 3. Create and manage product listings | A, B, C, D |
| 4. Search, filter, and discover products | A, B, C, D, E |
| 5. Buyer-seller messaging and listing status management | A, B, C, D |
| 6. Listing reports, content moderation, and user management | A, B, C, D |
| 7. System configuration, monitoring, and database backups | A, B |

## Notes

- The platform is initially intended exclusively for the Visayas State University campus community, including students, faculty members, university personnel, and authorized campus-based sellers.
- The marketplace supports both new and preloved products, including food, clothing, electronics, school supplies, and other permitted goods.
- The platform will not implement online payment processing, delivery services, or shipping integrations in the initial MVP.
- Buyers and sellers will communicate through the platform and independently arrange their transactions and campus meet-up locations.
- The platform will not function as an e-commerce payment processor. It will primarily facilitate product discovery and buyer-seller communication.
- Guest users may browse limited public listings but must authenticate to communicate with sellers or participate in marketplace activities.
- Only permitted products and services are allowed. Illegal, prohibited, or inappropriate listings are subject to removal.
- Product listings may have expiration periods to prevent outdated or unavailable products from remaining visible.
- The initial implementation will prioritize usability, organized product discovery, campus accessibility, and safe community participation.
