# An embarassingly simple environment configuration hash. Too little
# code to be its own library, really. Inflexible and only good for
# people who name environment variables exactly like I do.

module Configlet

  # What's at the front of our environment variables? This will be
  # upcased and a trailing semicolon will be added, so
  # <tt>Configlet[:foo]</tt> with a prefix of <tt>thunk</tt> maps to
  # the <tt>THUNK_FOO</tt> environment variable. Default is +nil+.

  attr_accessor :prefix

  # Duh.

  VERSION = "1.1.0"

  I = lambda { |v| v } #:nodoc:

  # Grab a config value. +key+ is translated to an unfriendly
  # environment name by upcasing, replacing all periods with
  # underscores, and prepending (with an underscore) the +prefix+.
  #
  # If the prefix is set to <tt>"thunk"</tt>, for example, calling
  # <tt>Configlet[:severity]</tt> will return the value of the
  # <tt>THUNK_SEVERITY</tt> environment variable, or
  # <tt>defaults["severity"]</tt> if the env var isn't set.

  def [] key
    mungers[key.to_s].call ENV[envify(key)] || defaults[key.to_s]
  end

  # Set an environment value. +key+ is translated to an unfriendly
  # environment name as in Configlet#[] above.

  def []= key, value
    ENV[envify(key)] = value
  end

  # Set one or more default values. Use "friendly" names, not env
  # vars, so a default for the <tt>THUNK_SECRET</tt> could be set
  # as <tt>Configlet.default :secret => "sssssh"</tt> (assuming a
  # <tt>"thunk"</tt> prefix).

  def default hash
    hash.each { |k, v| defaults[k.to_s] = v }
  end

  def defaults #:nodoc:
    @defaults ||= {}
  end

  def envify key #:nodoc:
    [prefix, key].compact.join("_").tr(".", "_").upcase
  end

  # Swanky block form. More pleasant to read when setting multiple
  # defaults, e.g.,
  #
  #    Configlet.for :myapp do
  #      default "email.from" => "noreply@myapp.com"
  #      default :host        => "myapp.local"
  #    end

  def for prefix, &block
    self.prefix = prefix
    instance_eval(&block)
  end

  # Mess with a value when it's retrieved. Useful for turning untyped
  # environment strings into numbers, booleans, enums, or class
  # instances. Here's how to munge a boolean:
  #
  #    Configlet.prefix = :thunk
  #    Configlet.munge(:enabled) { |v| "true" == v }
  #
  #    ENV["THUNK_ENABLED"] = "false"
  #    Configlet[:enabled] # => false

  def munge key, &block
    mungers[key.to_s] = block
  end

  def mungers #:nodoc:
    @mungers ||= Hash.new { |h, k| I }
  end

  # Set prefix to +nil+, clear defaults and mungers.

  def reset
    self.prefix = nil

    defaults.clear
    mungers.clear
  end

  extend self
end
