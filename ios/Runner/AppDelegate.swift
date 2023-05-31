import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
    
//       let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
      
// //      print("we are printing the swift stuff")
// //      print("\(path)")
//       let CHANNEL = FlutterMethodChannel(name: "com.flutter.gpuiosbundle/getPath", binaryMessenger: controller.binaryMessenger)
      
//       CHANNEL.setMethodCallHandler ({
//          [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          
//           guard call.method == "printy" else {
//               result(FlutterMethodNotImplemented)
//               return
//             }
           
//        //   print("we are here")
//           var arg: String!
          
//           arg = call.arguments as? String
          
//           let val = arg!
          
//         //  print(arg)
          
//           let key = controller.lookupKey(forAsset: String(val))
//           let mainBundle = Bundle.main
          
//         //  var tmp: String?
          
     
//           //print(key)
//           let tmp = mainBundle.path(forResource: key, ofType: nil)
          
//         //   var path: String

//         //   path = ""
          
//         //   if let filepath = Bundle.main.path(forResource: key, ofType: nil)
//         //   {
//         //       do
//         //       {
//         //           let contents = try String(contentsOfFile: filepath)
//         //         //  print(contents)
                  
//         //           path = filepath

//         //         // print(filepath)

//         //       }
//         //       catch
//         //       {
//         //           print("Contents could not be loaded.")
//         //       }
//         //   }
//         //   else
//         //   {
//         //       print(key)
//         //       print("not found.")
//         //   }
          
//         //  // print(tmp)
          
//           let path = tmp!

//          //let path = filepath!
          
//           //print(path)
//           result (path)
          
//         }
//       )
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
