node {
	stage 'Checkout and Setup'
		checkout scm
		sh 'bundle install'
	stage 'Test'
		sh 'bundle exec fastlane unit_tests'
}