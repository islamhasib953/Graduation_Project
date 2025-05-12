# Notification System Documentation

This document outlines the notification system implemented in the application, including the types of notifications, their descriptions, recipients, triggers, and schedules.

## Notification Types

| **Notification Type**         | **Description**                                                                 | **Recipient**     | **Trigger**                                              | **Timing**                          |
|-------------------------------|---------------------------------------------------------------------------------|-------------------|----------------------------------------------------------|-------------------------------------|
| Profile Updated               | Sent when a parent's profile is updated.                                       | Parent            | Update user profile (`updateUserProfile`)                | Immediate                           |
| Account Deleted               | Sent when a parent deletes their account.                                     | Parent            | Delete user profile (`deleteUserProfile`)                | Immediate                           |
| Logged Out                    | Sent when a parent logs out.                                                  | Parent            | User logout (`logoutUser`)                               | Immediate                           |
| Account Created               | Sent when a new account is created (parent or doctor).                        | Parent/Doctor     | Register new user (`registerUser`)                       | Immediate                           |
| Logged In                     | Sent when a user logs in.                                                     | Parent/Doctor     | User login (`loginUser`)                                 | Immediate                           |
| FCM Token Updated             | Sent when a parent's FCM token is updated.                                    | Parent            | Save FCM token (`saveFcmToken`)                          | Immediate                           |
| Medicine Reminder             | Reminder for a child's scheduled medicine doses.                              | Parent            | Scheduled medicine time (`scheduleNotifications`)         | Every minute (±5 minutes of dose time) |
| Vaccination Reminder          | Reminder for a child's vaccination due date (day before and on due date).     | Parent            | Pending vaccination (`scheduleNotifications`)             | 8:00 AM                             |
| Delayed Vaccination           | Reminder for a child's overdue vaccinations (after due date).                 | Parent            | Delayed vaccination (`scheduleNotifications`)             | 8:00 AM                             |
| Missed Vaccination            | Notification for a child's missed vaccinations (7 days after due date).       | Parent            | Missed vaccination (`scheduleNotifications`)              | 8:00 AM                             |
| Growth Update                 | Notification for a new growth record added for a child.                       | Parent            | Add growth record (`createGrowth`)                       | 10:00 AM                            |
| Growth Alert                  | Alert for significant height deviation for a child.                           | Parent            | Height deviation > 10 cm (`createGrowth`, `updateGrowth`) | Immediate                           |
| Appointment Reminder          | Reminder for a child's appointment one day before.                            | Parent/Doctor     | Accepted appointment for next day (`scheduleNotifications`) | 8:00 AM                             |
| New Medicine Added            | Notification for adding a new medicine for a child.                           | Parent            | Add medicine (`createMedicine`)                          | Immediate                           |
| Medicine Updated              | Notification for updating a child's medicine.                                 | Parent            | Update medicine (`updateMedicine`)                       | Immediate                           |
| Medicine Deleted              | Notification for deleting a child's medicine.                                 | Parent            | Delete medicine (`deleteMedicine`)                       | Immediate                           |
| New Vaccination Added         | Notification for adding a new vaccination for all children.                   | Parent            | Add vaccination (`createVaccinationForAllChildren`)       | Immediate                           |
| Vaccination Updated           | Notification for updating a child's vaccination.                              | Parent            | Update vaccination (`updateUserVaccination`)             | Immediate                           |
| Vaccination Deleted           | Notification for deleting a child's vaccination.                              | Parent            | Delete vaccination (`deleteUserVaccination`)             | Immediate                           |
| Bracelet Notification         | Manual notification related to a child's bracelet.                            | Parent            | Manual request via `/api/notifications/bracelet`         | Immediate                           |
| General Notification          | General notification for all parents or doctors.                              | Parent/Doctor     | Manual request via `/api/notifications/send-general`     | Immediate                           |

## Notes
- **Recipient Clarification**: Notifications listed with "Parent" as the recipient are sent to the parent (User) associated with the child (`childId`) specified in the notification. Each notification is linked to a specific child, allowing multiple children per parent to have independent notifications (e.g., medicine reminders, vaccinations).
- **Immediate** notifications are sent as soon as the triggering action occurs.
- **Scheduled** notifications are managed by `node-cron` jobs in `scheduleNotifications.js` and are checked every minute or at specific times (e.g., 8:00 AM, 10:00 AM).
- Notifications are stored in the `Notification` collection in MongoDB with fields like `status` ("pending", "sent", "failed") and `sentAt` to track their state and prevent duplicates.
- The system uses Firebase Cloud Messaging (FCM) to send push notifications, requiring a valid `fcmToken` for each recipient (parent or doctor).

## Testing Instructions
To test notifications from the frontend (e.g., Flutter):
1. Ensure Firebase is configured correctly in both backend (`firebase-config.js`) and frontend.
2. Send the `fcmToken` from the frontend to the backend via `/api/users/save-fcm-token`.
3. Trigger immediate notifications (e.g., login, update profile) and verify receipt on the parent's device.
4. Add test data (e.g., medicines with near-future times, vaccinations with today's due date) to trigger scheduled notifications for specific children.
5. Check the `Notification` collection in MongoDB to verify storage, status, and association with the correct `childId`.