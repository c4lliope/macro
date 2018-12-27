# Literate Javascript
# implementation of a full-featured web macro recorder.
#
# This library is designed to be as lightweight as possible,
# while supporting a number of the most common browsers.
#
# Under the hood,
# it uses the wonderful Capybara library along with Selenium Webdriver.
# Although the first pass at implementation does not support Docker containers,
# a release is planned for end of January 2019
# that adds container support based on the approaches outlined in:
# https://gist.github.com/thecalliopecrashed/879ad625269541728167560bdcf9ccb7
#
# Our installation instructions only support Apple computers,
# but work is in progress to expand to multiple platforms.
#
# Development Calendar
# --------------------
#
# January 2019:

# * [ ] Add Docker container support for the macro recorder
#   * Generated recordings should execute in containerized environments.
#
# * [ ] Design Assemble integration for the macro recorder
#
# * [ ] Support recording parameters;
#   * form field variables (w/ defaults!)
#   * etc
#
# 2018.12.27
#
# First pass implementation; detect link clicks
#
# Install
# -------
#
# ```bash
# # Use homebrew to fetch the rest of the dependencies
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#
# brew install geckodriver ruby-install
#
# ruby-install --latest ruby
#
# # Take some action to set the current ruby on the path
# gem install capybara
# gem install selenium-Webdriver
#
# echo 'PATH=~/.rubies/ruby-2.5.3:$PATH' >> ~/.bashrc
# PATH=~/.rubies/ruby-2.5.3:$PATH
# ```
#
# Usage
# -----
#
# Start the program with:
#
# ```bash
# ruby script.rb
# ```
#
# The program opens <http://example.com> in a browser window.
# From there, every event that the user takes is recorded
# into `capybara` syntax.
#
# Known Actions
# -------------
#
# Support for recording different user actions
# will be added incrementally as need arises.
#
# So far, the script watches for the user to:
#
# * Click a link
#
# Assemble Integration
# --------------------
#
# This library is a core component of Assemble,
# and when run in an Assembled environment,
# logs user action to an Assemble server.
#
# This function is not yet supported, however.
# The exact design for this feature is scheduled for January 2018.

require "selenium-webdriver"
require "capybara"

web = Capybara::Session.new(:selenium)

set_up_monitoring = <<-JS
function clicked_element(e){
  var target = e.target;
  var tag = [];
  tag.tagType = target.tagName.toLowerCase();
  tag.tagClass = target.className.split(' ');
  tag.id = target.id;
  tag.parent = target.parentNode;
  tag.text = target.text

  return tag;
}

var tagsToIdentify = ['img','a'];

document.body.onclick = function(e){
  elem = clicked_element(e);

  for (i=0; i<tagsToIdentify.length; i++){
    if (elem.tagType == tagsToIdentify[i]){
      console.log(`web.click_link(${JSON.stringify(elem.text)})`);

      // TODO
      // Use an Assemble server
      // to write this to a text file on the Desktop,
      // not the console.
      //
      // window.assemble.run("macros")`
      //   MacroStep.create(
      //     capybara_code: "web.click_link(${JSON.stringify(elem.text)})"
      //   )
      // `

      // Answer the question,
      // "should the browser proceed with its normal handling of the event?
      return true;
    }
  }
};
JS

web.visit("http://example.com")
# This must be done on every page load
web.driver.execute_script(set_up_monitoring)
