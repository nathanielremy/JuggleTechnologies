const functions = require('firebase-functions');
const admin = require('firebase-admin'); // The Firebase Admin SDK to access the Firebase Realtime Database.

admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//

exports.observeOffer = functions.database.ref('/taskOffers/{taskId}/{userId}')
  .onCreate((snapshot, context) => {
    var userId = context.params.userId;
    var taskId = context.params.taskId;

    var offer = snapshot.val();
    console.log(offer.offerPrice);

    return admin.database().ref('/users/' + offer.taskOwnerUserId).once('value', snapshot => {
      var user = snapshot.val();

      console.log(user.firstName);

      var message = {
        notification : {
          title : 'Tienes una nueva oferta de €' + offer.offerPrice + '!!'
        },
        data : {
          notificationType : 'offer',
          taskId : taskId
        },
        token : user.fcmToken
      };

      // Send a message to the device corresponding to the provided
      // registration token.
      admin.messaging().send(message)
        .then((res) => {
          // Response is a message ID string.
          console.log('Successfully sent message:', res);
          return
        }).catch((error) => {
          console.log('Error sending message:', error);
        });
     });
  });

exports.observeReview = functions.database.ref('/reviews/{userId}/{reviewId}')
  .onCreate((snapshot, context) => {
    var userId = context.params.userId;
    var review = snapshot.val();

    return admin.database().ref('/users/' + userId).once('value', snapshot => {
      var user = snapshot.val();

      var message = {
        notification : {
          title : 'Tienes una nueva reseña de ' + review.rating + ' estrellas!!'
        },
        data : {
          notificationType : 'review',
          isFromUserPerspective : review.isFromUserPerspective === true ? 'true' : 'false'
        },
        token : user.fcmToken
      };

      // Send a message to the device corresponding to the provided
      // registration token.
      admin.messaging().send(message)
        .then((res) => {
          // Response is a message ID string.
          console.log('Successfully sent message:', res);
          return
        }).catch((error) => {
          console.log('Error sending message:', error);
        });
    });
});

// //This fucntion sends test push notifications to Remy's iPhone 8
exports.sendTestPushNotification = functions.https.onRequest((req, res) => {
  res.send('Attempting to send push notification.');
  console.log('--LOGGER : Attempting to send push notification');

  var message = {
    notification : {
      title : 'My name is Leo',
      body : 'Open to see my 😂'
    },
    data : {
      score : '850',
      time : '2:45'
    },
    token : 'd_37Qc8YL0ATnV3jmkGkbR:APA91bEOIhUgSsy_C5OCJDoxMP-gq3TMpirta_OiT6E4iWD6gNzYfqT_POpnjiRkAXj6qV6xkDtHjdD4LsVthKXS-yLb8r1jN6peVbeIKZXVQNjNTcOdqCSD1YSR549870YjZ8jlAbhZ'
  };

  // Send a message to the device corresponding to the provided
  // registration token.
  admin.messaging().send(message)
    .then((res) => {
      // Response is a message ID string.
      console.log('Successfully sent message:', res);
      return
    })
    .catch((error) => {
      console.log('Error sending message:', error);
    });
});