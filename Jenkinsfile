node {
	stage 'Checkout and Setup'
		checkout scm
	stage 'Test'
		sh 'xcodebuild \
  			-workspace BSWInterfaceKit.xcworkspace \
  			-scheme BSWInterfaceKit \
 			-sdk iphonesimulator \
  			-destination 'platform=iOS Simulator,name=iPhone 11' \
  			test'
}