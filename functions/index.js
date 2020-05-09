const functions = require('firebase-functions');
const admin = require('firebase-admin'); // The Firebase Admin SDK to access the Firebase Realtime Database.

admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
  response.send('Hello from Juggle!');
});

exports.observeReview = functions.database.ref('/reviews/{uid}/{reviewId}')
  .onCreate((snapshot, context) => {
    var uid = context.params.uid;
    var review = snapshot.val();

    return admin.database().ref('/users/' + uid).once('value', snapshot => {

      var user = snapshot.val();

      console.log('User: ' + user.firstName);

      var message = {
        notification : {
          title : 'Nueva reseña de ' + review.rating + ' estrellas!!'
        },
        data : {
          score : '850',
          time : '2:45'
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
        })
        .catch((error) => {
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
      body : 'Open to see my dick'
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
