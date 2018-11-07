# DVS Public iOS App
##	System Requirements
###	Software Requirements
-	Xcode 9.4.1
-	Minimum iOS version 9.0
-	Mac OS 10.13.4


##	reCAPTCHA Configuration
For reCAPTCHA configurations go to this [link](https://www.google.com/recaptcha/admin#list):
1.	In Register a new site section enter label for app e.g. Android DVS Public.
2.	Select “Invisible” type of reCAPTCHA
3.	Enter Domain Name.
4.	Accept the reCAPTCHA Terms of Service
5.	Click on “Register” button.
6.	Copy “Site Key”.

##	App Configuration
- To change any icon open Assets.xcaassets file in Xcode and select your required icon
-	Open info.plist file and enter API Gateway URL “APIGatewayURL” field
- Enter the domain name in “ReCaptchaDomain” field which you have mentioned in reCAPTCHA configuration
- Enter the site key (copied in reCAPTCHA configuration) in value section of “ReCaptchaKey” field
