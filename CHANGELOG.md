# Changelog

## v2.5.0

### Requirements

* Upgrades `faraday` dependency from v1 to v2. `faraday_middleware` was dropped because its JSON middleware is now part of `faraday`, and `basic_auth` was replaced by the `authorization` middleware.
* Requires `faraday` 2.14.4 or newer, the first version that passes JSON parser options as keywords and therefore works with `json` 3. Earlier `faraday` 2.x versions raise `Faraday::ParsingError` when parsing responses with `json` 3.
* Requires Ruby 3.0 or newer, the minimum `faraday` supports since 2.9. Ruby 2.x is no longer supported.

### Behavior changes

* `InquireResponse#success?` now returns `false` when the queried transaction has `respstat` B (retry) or C (declined), and `errors` carries the API `resptext`. It previously returned `true` for every inquiry. Code that used `success?` only to know whether the inquiry request itself worked will now see `false` for declined transactions; use `setlstat` if you need the settlement state.
* The service endpoints write the `Faraday::ResourceNotFound` message to stderr instead of stdout, and `submit` still returns `nil` in that case. They use `$stderr.puts` rather than `Kernel#warn`, which is silenced when warnings are disabled with `-W0`.

### Other changes

* Removes the `bundler` development dependency, which pinned Bundler to 1.x and made `bundle install` fail on Ruby 3.
* Constrains `minitest` to 5.x, since the test suite relies on the global expectations that Minitest 6 removed.
* Adds the missing `errors` and `success?` to `CaptureResponse`, which had no way to report a declined (`respstat` C) or retry (`respstat` B) capture.
* Runs the test suite against `json` 3, so the compatibility fixed in this release stays verified.
* Replaces the defunct `.travis.yml` with a GitHub Actions matrix covering Ruby 3.0 to 3.4, `faraday` 2.14.4 and newer, and `json` 2 and 3.

## v2.4.2

* Add cof parameters (cof, cofpermission, and cofscheduled) in the list of optional request parameters. Before they didn't appear in any list of parameters.

## v2.4.1

* Upgrades `faraday` and `faraday_middleware` dependency versions to use versions 1.10 and 1.2, respectively.

## v2.4.0

* Upgrades `faraday` and `faraday_middleware` dependency versions to use ones that works with ruby 3.0.

## v2.3.0

* Added the following fields to response objects (@shivashankar-ror):
  - CaptureResponse: `:respproc, :resptext, :commcard, :respstat, :respcode, :batchid, :token`
  - InquireResponse: `:capturedate, :batchid, :token, :authdate, :lastfour, :name, :currency, :settledate`
  - ProfileGetResponse: `:gsacard, :auoptout`

* Added support for Bin Service (@shivashankar-ror)

## v2.2.0

* Add `token` field to Profile Service for create/update responses since this field can potentially be included in the response if a token hadn't already been created for that particular profile. (@mauriciozaffari)

## v2.1.0

* Add ability to pass connection options to the Faraday connection (@jhanggi)

## v2.0.1

* Upgrades `faraday` and `faraday_middleware` dependency versions

## v2.0.0

* Added support for Profile Service (@AndreiBujenitsa)
* Removes Deposit Service support

## v1.1.1

* Reintroduced Capture and Inquire settlement status constants to resolve some compatibility issues

## v1.1.0

* Adding the `profileid` to the Authorization Response.
* Added fields necessary for Authorization Capture requests

## v1.0.0

* First version! Don't downgrade from here!
