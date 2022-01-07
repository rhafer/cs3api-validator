package login

import (
	"github.com/cucumber/godog"
	"github.com/owncloud/cs3api-validator/featurecontext"
)

// LoginFeatureContext holds values which are used across test steps
type LoginFeatureContext struct {
	*featurecontext.FeatureContext
}

func NewLoginFeatureContext(fc *featurecontext.FeatureContext) *LoginFeatureContext {
	return &LoginFeatureContext{FeatureContext: fc}
}

func (f *LoginFeatureContext) RegisterSteps(sc *godog.ScenarioContext) {
	// steps
	sc.Step(`^user "([^"]*)" has logged in with password "([^"]*)"$`, f.UserHasLoggedIn)
	sc.Step(`^user "([^"]*)" has logged in with the token of the public-share "([^"]*)"$`, f.UserHasLoggedInWithTheTokenOfThePublicshare)

	// cleanup

}
