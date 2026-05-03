// functions/index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// لما تتغيّر أي وثيقة داخل complaints/{complaintId}
exports.notifyOnComplaintStatusChange = functions.firestore
  .document("complaints/{complaintId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    const oldStatus = before.status;
    const newStatus = after.status;

    // إذا ماكو تغيير في حالة الشكوى، لا تسوي شي
    if (!oldStatus || !newStatus || oldStatus === newStatus) {
      return null;
    }

    const userId = after.userId;
    if (!userId) {
      console.log("No userId on complaint, skip notification");
      return null;
    }

    // نقرأ المستخدم حتى نجيب fcmToken + تفضيلات الإشعارات
    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    if (!userDoc.exists) {
      console.log("User doc not found for", userId);
      return null;
    }

    const userData = userDoc.data() || {};
    const fcmToken = userData.fcmToken;
    const notificationPrefs = userData.notificationPrefs || {};
    const complaintStatusEnabled =
      notificationPrefs.complaintStatus !== false; // الافتراضي: مفعّل

    if (!complaintStatusEnabled) {
      console.log("Complaint status notifications disabled for", userId);
      return null;
    }

    if (!fcmToken) {
      console.log("No fcmToken for user", userId);
      return null;
    }

    const statusLabel = (s) => {
      switch (s) {
        case "pending":
          return "قيد المراجعة";
        case "resolved":
          return "تم الحل";
        case "rejected":
          return "مرفوضة";
        case "new":
        case "neww":
          return "جديدة";
        default:
          return "غير محدد";
      }
    };

    const title = "تحديث حالة الشكوى";
    const body = `تم تغيير حالة الشكوى من ${statusLabel(
      oldStatus
    )} إلى ${statusLabel(newStatus)}.`;

    const message = {
      token: fcmToken,
      notification: {
        title,
        body,
      },
      data: {
        complaintId: context.params.complaintId,
        oldStatus,
        newStatus,
        type: "complaint_status",
      },
    };

    try {
      // 1) إرسال إشعار FCM للموبايل
      await admin.messaging().send(message);
      console.log("Notification sent to", userId);

      // 2) تخزين الإشعار في Firestore حتى يظهر في شاشة الإشعارات داخل التطبيق
      await admin.firestore().collection("notifications").add({
        userId,
        title,
        body,
        type: "complaint_status",
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      console.error("Error sending FCM or saving notification:", e);
      return null;
    }
  });