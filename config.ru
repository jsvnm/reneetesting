$: << File.dirname(__FILE__)
require 'myapp'
require 'rack/bug'

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::Bug
run MyApp
