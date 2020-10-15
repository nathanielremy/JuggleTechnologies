const functions = require('firebase-functions');
const admin = require('firebase-admin'); // The Firebase Admin SDK to access the Firebase Realtime Database.

var db = admin.database();
// var ref = db.ref("juggletechnologies-78310");

admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//

exports.observeTaskCompletion = functions.database.ref('/userTasks/{userId}/{taskId}/taskStatus')
.onWrite((snapshot, context) => {
   let userId = context.params.userId;
   let taskId = context.params.taskId;
   let status = snapshot.after.val();

   console.log(status);

   if (status !== 2) {
     console.log(status);
     return;
   }

   return admin.database().ref('/users/' + userId).once('value', snapshot => {
     let user = snapshot.val();

     let message = {
       notification : {
         title : 'Tu tarea ha sido completada!!',
         body : 'Deja una reseña a su Juggler para ayudar a los otros usuarios 😊'
       },
       data : {
         notificationType : 'taskCompletion',
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

exports.observeMessage = functions.database.ref('/messages/{messageId}')
  .onCreate((snapshot, context) => {
    let userMessage = snapshot.val();

    return admin.database().ref('/users/' + userMessage.toUserId).once('value', snapshot1 => {
      let toUser = snapshot1.val();

      return admin.database().ref('/users/' + userMessage.fromUserId).once('value', snapshot2 => {
        let fromUser = snapshot2.val();

        let message = {
          notification : {
            title : 'Mensaje de ' + fromUser.firstName + ' ' + fromUser.lastName + ':',
            body : userMessage.text
          },
          data : {
            notificationType : 'message',
            taskId : userMessage.taskId,
            fromUserId : userMessage.fromUserId,
            toUserId : userMessage.toUserId
          },
          token : toUser.fcmToken
        };

        // Send a message to the device corresponding to the provided
        // registration token.
        admin.messaging().send(message)
          .then((res) => {
            // Response is a message ID string.
            console.log('Successfully sent message:', res);
            // newMessageNotification(userMessage, 0);
            return
         }).catch((error) => {
            console.log('Error sending message:', error);
         });
      });
    });
});

// function newMessageNotification(message, type) {
//   //Type of notifications are 0 = newMessage, 1 = offerMade, 2 = offerAccepted, 3 = taskCompleted, 4 = reviewMade
//
//   if (type === 0) {
//     console.log("messageType");
//   }
//
//   var usersRef = ref.child("notifications/" + message.toUserId);
//   usersRef.set({
//         text : message.text,
//         fromUser : message.fromUserId
//   });
//
//   return
// }

exports.observeOffer = functions.database.ref('/taskOffers/{taskId}/{userId}')
  .onCreate((snapshot, context) => {
    let userId = context.params.userId;
    let taskId = context.params.taskId;

    let offer = snapshot.val();

    return admin.database().ref('/users/' + offer.taskOwnerUserId).once('value', snapshot1 => {
      let user = snapshot1.val();

      let message = {
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

exports.observeJugglerTaskStatus = functions.database.ref('/jugglerTasks/{userId}/{taskId}/taskStatus')
 .onWrite((snapshot, context) => {
    let userId = context.params.userId;
    let status = snapshot.after.val();

    if (status !== 1) {
      console.log('Status other than 1');
      return 0;
    }

    return admin.database().ref('/users/' + userId).once('value', snapshot => {
      let  user = snapshot.val();

      let message = {
        notification : {
          title : 'Tu oferta ha sido aceptada!!',
          body : 'Es tu turno de terminar la tarea y ganar tu paga'
        },
        data : {
          notificationType : 'offerAcceptance'
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
    let userId = context.params.userId;
    let review = snapshot.val();

    return admin.database().ref('/users/' + userId).once('value', snapshot => {
      let user = snapshot.val();

      let message = {
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

//This fucntion sends test push notifications to Remy's iPhone 8
// exports.sendTestPushNotification = functions.https.onRequest((req, res) => {
//   res.send('Attempting to send push notification.');
//   console.log('--LOGGER : Attempting to send push notification');
//
//   let message = {
//     notification : {
//       title : 'My name is Leo',
//       body : 'Open to see my 😂'
//     },
//     data : {
//       score : '850',
//       time : '2:45'
//     },
//     token : 'd_37Qc8YL0ATnV3jmkGkbR:APA91bEOIhUgSsy_C5OCJDoxMP-gq3TMpirta_OiT6E4iWD6gNzYfqT_POpnjiRkAXj6qV6xkDtHjdD4LsVthKXS-yLb8r1jN6peVbeIKZXVQNjNTcOdqCSD1YSR549870YjZ8jlAbhZ'
//   };
//
//   // Send a message to the device corresponding to the provided
//   // registration token.
//   admin.messaging().send(message)
//     .then((res) => {
//       // Response is a message ID string.
//       console.log('Successfully sent message:', res);
//       return
//     })
//     .catch((error) => {
//       console.log('Error sending message:', error);
//     });
// });
