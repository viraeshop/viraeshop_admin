importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

   /*Update with yours config*/

  firebase.initializeApp({
    apiKey: "AIzaSyCoiA-jkFzDVNjX4obb7JY8QDqItTKLV84",
    authDomain: "vira-eshop.firebaseapp.com",
    projectId: "vira-eshop",
    storageBucket: "vira-eshop.appspot.com",
    messagingSenderId: "903623659021",
    appId: "1:903623659021:web:c1428c083171632c3d8f44",
    measurementId: "G-KWT09K6YHG"
  });
  const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});