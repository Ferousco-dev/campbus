const admin = require("firebase-admin");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

function formatAmount(amount) {
  if (typeof amount !== "number") return "0";
  return amount.toFixed(0);
}

function categoryLabel(category) {
  switch (category) {
    case "transport":
      return "transport";
    case "topup":
      return "top-up";
    case "purchase":
      return "purchase";
    case "subscription":
      return "subscription";
    case "refund":
      return "refund";
    case "wifi":
      return "WiFi";
    default:
      return "transaction";
  }
}

exports.onTransactionCreate = onDocumentCreated(
  "users/{userId}/transactions/{txId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const userId = event.params.userId;
    const userRef = db.collection("users").doc(userId);
    const userSnap = await userRef.get();
    const userData = userSnap.data() || {};
    const tokens = Array.isArray(userData.fcmTokens)
      ? userData.fcmTokens
      : [];

    const isCredit = data.type === "credit";
    const amount = formatAmount(data.amount);
    const category = categoryLabel(data.category);
    const title = isCredit ? "Wallet credited" : "Wallet debited";
    const message = isCredit
      ? `Your wallet was credited ₦${amount} for ${category}.`
      : `Your wallet was debited ₦${amount} for ${category}.`;

    await userRef.collection("notifications").add({
      title,
      message,
      type: "transaction",
      isRead: false,
      amount: data.amount ?? 0,
      isCredit,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      source: "transaction",
      txId: event.params.txId,
    });

    if (!tokens.length) return;

    const payload = {
      notification: {
        title,
        body: message,
      },
      data: {
        title,
        message,
        type: "transaction",
        amount: String(data.amount ?? 0),
        isCredit: String(isCredit),
        txId: event.params.txId,
      },
    };

    await messaging.sendEachForMulticast({
      tokens,
      ...payload,
    });
  }
);
