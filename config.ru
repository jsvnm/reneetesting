$: << File.dirname(__FILE__)
require 'myapp-sinatra'
require 'rack/bug'

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::Bug
run MyApp
