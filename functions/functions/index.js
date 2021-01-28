const functions = require('firebase-functions');

const admin = require('firebase-admin');
const { messaging } = require('firebase-admin');
admin.initializeApp()

exports.sendNotification = functions.firestore.document("Tokens/{tokens}/notifications/{notification}")
    .onCreate(async(snapshot, context) => {
        try {
            const uid = context.params.user;
            if (uid != null) {
                const notificationDocument = snapshot.data()
                const notificationMessage = notificationDocument.message;
                const notificationTitle = notificationDocument.title;
                const userDoc = await admin.firestore().collection("Tokens").doc(uid).get();
                const fcmToken = userDoc.data().fcmToken
                const message = {
                    "notification": {
                        title: notificationTitle,
                        body: notificationMessage
                    },
                    to: fcmToken
                }
                return admin.messaging().send(message)
            }
        } catch (error) {
            console.log(error);
        }

    })