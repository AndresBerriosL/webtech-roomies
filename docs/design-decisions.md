# Roomies — Design Decisions

## Additional entities

We introduced `properties_amenities` as a join table between properties and amenities because a property can offer several amenities and the same amenity can belong to many properties.

We also introduced `saved_listings` as a join table between users and listings. A seeker may save several listings, and the same listing may be saved by several users.

We did not create separate Host and Seeker entities. Both are represented by `users`, because the project states that the same member may act as a host for their own listings and as a seeker for other users' listings.

## Listing lifecycle

A listing has one of five states:

- `draft`
- `published`
- `reserved`
- `rented`
- `withdrawn`

A listing begins as a draft. Once published, it becomes visible and accepts applications. When one application is accepted, the listing becomes reserved. After the selected applicant moves in, it becomes rented. A listing may also be withdrawn by its host or by a moderator.

## Application lifecycle

An application has one of five states:

- `pending`
- `shortlisted`
- `accepted`
- `rejected`
- `withdrawn`

Applications begin as pending. A host may shortlist an applicant in order to arrange a visit. The host may later accept or reject the application, while the seeker may withdraw it.

When one application is accepted, all other pending or shortlisted applications for the same listing must be rejected and the listing becomes reserved.

## Assumptions

We assume that `minimum_stay` and `intended_stay` are measured in months and are stored as integers.

Visitors are not stored as users because they are not signed in. Registered users have either the `member` or `moderator` role.

Listing photographs are not modeled as a separate domain entity because the project specifies that they will later be managed through Active Storage.