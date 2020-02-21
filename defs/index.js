const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createUserProfile = functions.auth.user().onCreate((user) => {

  try {

    return admin.firestore().collection("users").doc(user.uid).set({
        'userId': user.uid,
        'userEmail': 'Не указан',
        'userName': 'Не указан',
        'userSureName': 'Не указан',
        'userPhone': user.phoneNumber,
        'userImage': 'Не указан',
        'createdOn' : user.metadata.creationTime,
        'pushToken': 'Не указан',
        'searchIndex': [],
        'car': {
          'carMark': 'Не указан',
          'carModel': 'Не указан',
          'carColor': 'Не указан',
          'carVin': 'Не указан',
          'carImages': [],
          'carStsImages': [],
          'taxiLicenseNum': 'Не указан',
          'taxiLicenseImages': [],
          'driverLicenseNum': 'Не указан',
          'driverLicenseImages': [],
        },
        'userStatus': 'Новичок',
        'isDriver': false,
        'userCity': 'Не указан',
        'isOnline': false,
        'userType': 'Пассажир',
        'isConfirmed': false,
        'isPaid': false,
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