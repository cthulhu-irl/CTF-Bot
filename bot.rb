require 'cinch'
require_relative 'plugins/ctf'
require_relative 'plugins/quit'
require_relative 'plugins/version'
require_relative 'plugins/help'
require_relative 'util/period'

begin
  require_relative 'config'
rescue LoadError
  puts "Could not find 'config.rb'. You can find the template in 'example-config.rb'."
  exit 1
end

unless CONFIG[:log_path].nil?
  $stdout.reopen(CONFIG.log_path, 'a')
  $stderr.reopen(CONFIG.log_path, 'a')
end

help_message = {
  "ctfs" => "display info about all events\n",
  "current" => "display info about current events\n",
  "upcoming" => "display info about upcoming events\n",
  "next" => "display info about the next event\n",
  "update" => "update the database (this happens automatically every hour)\n",
  "creds" => "modify the credentials database\n",
  "load" => "load the credentials database (if modified manually)\n"
}

help_message = help_message.map { |k, v| "#{CONFIG.prefix}#{k} - #{v}" }.join

bot = Cinch::Bot.new do
  configure do |c|
    c.server = CONFIG.server
    c.channels = CONFIG.channels
    c.nick = CONFIG.nick
    c.user = 'CTF-Bot'
    c.plugins.plugins = [CTFPlugin, QuitPlugin, VersionPlugin, HelpPlugin]
    c.plugins.prefix = /^#{CONFIG.prefix || '!'}/
    c.plugins.options[CTFPlugin] = {
      lookahead: CONFIG.lookahead,
      event_limit: CONFIG.event_limit,
      mark_highschool: CONFIG.mark_highschool,
      announce_periods: CONFIG.announcement_periods,
      help: help_message
    }
    c.plugins.options[QuitPlugin] = {
      authorized: CONFIG.admins,
      message: 'Leaving...'
    }
    c.plugins.options[VersionPlugin] = { version: 'CTF-Bot v0.1. Get the source at https://github.com/LiquidLemon/CTF-Bot' }
  end
end

bot.loggers.level = CONFIG.log_level

Process.daemon(true, true) if CONFIG.daemonize
bot.start
