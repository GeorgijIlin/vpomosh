const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createUserProfile = functions.auth.user().onCreate((user) => {

  try {

    return admin.firestore().collection("users").doc(user.uid).set({
        'userId': user.uid,
        'userName': 'Null',
        'userPhone': user.phoneNumber,
        'userImage': 'Null',
        'createdOn' : user.metadata.creationTime,
        'pushToken': 'Null',
        'searchIndex': [],
        'userCity': 'Null',
        'userType': 0,
        'userView': 0,
      }).then(() => {

        var splitList = user.phoneNumber.split(" ");
        var indexList = [];

        for (var i = 0; i < splitList.length; i++) {
            for (var y = 1; y < splitList[i].length + 1; y++) {
                indexList.push(splitList[i].substring(0, y).toLowerCase());
             }
        }

        const ref = admin.firestore().collection('users').doc(user.uid)

        console.log('------------searchIndex', indexList);

        return ref.get().then(() => {
            return ref.update({
               'searchIndex': indexList
            }, {merge: true});
        })

      });

  } catch (err) {
    console.error(err);
  }
});

exports.addPeerUserToCHats = functions.firestore
    .document('messages/{groupId1}/{groupId2}/{message}')
    .onCreate((snap, context) => {

        console.log('----------------start [Add peer user to chats] function--------------------')

        const doc = snap.data()

        const idFrom = doc.idFrom
        const idTo = doc.idTo
        const currentName = doc.currentName
        const peerName = doc.peerName
        const content = doc.content
        const timestamp = doc.timestamp

        // ref to the parent document
        const docRef = admin.firestore().collection('users').doc(idFrom).collection('chats').doc(idTo)

        return docRef.get().then(snap => {
          return docRef.set({
            "userId": idTo,
            'userName': peerName,
            "uid": idFrom,
            'lastMessage': content,
            'timestamp': timestamp,
          }, {merge: true});
        })
});

exports.addCurrentUserToChats = functions.firestore
    .document('messages/{groupId1}/{groupId2}/{message}')
    .onCreate((snap, context) => {

        console.log('----------------start [Add current user to chats] function--------------------')

        const doc = snap.data()
        const idFrom = doc.idFrom
        const idTo = doc.idTo
        const currentName = doc.currentName
        const peerName = doc.peerName
        const content = doc.content
        const timestamp = doc.timestamp

         // ref to the parent document
        const docRef = admin.firestore().collection('users').doc(idTo).collection('chats').doc(idFrom)

        return docRef.get().then(snap => {
            return docRef.set({
                "userId": idFrom,
                'userName': currentName,
                "uid": idFrom,
                'lastMessage': content,
                'timestamp': timestamp,
            }, {merge: true});
        })
});