class Recurrence
  module Base
    FREQUENCY = %w(day week month year)

    attr_reader :event

    def self.included(base) #:nodoc:
      base.extend ClassMethods
    end

    # Holds default_until_date configuration.
    #
    module ClassMethods #:nodoc:
      def default_until_date
        @default_until_date ||= Date.new(2037, 12, 31)
      end

      def default_until_date=(date)
        @default_until_date = if date.is_a?(String)
          Date.parse(date)
        else
          date
        end
      end
    end

    def initialize(options)
      raise ArgumentError, ':every option is required' unless options.key?(:every)
      raise ArgumentError, 'invalid :every option'     unless FREQUENCY.include?(options[:every].to_s)

      @options = initialize_dates(options)
      @options[:interval] ||= 1

      @event = case @options[:every].to_sym
        when :day
          Recurrence::Event::Daily.new(@options)
        when :week
          Recurrence::Event::Weekly.new(@options)
        when :month
          Recurrence::Event::Monthly.new(@options)
        when :year
          Recurrence::Event::Yearly.new(@options)
      end
    end

    def reset!
      @event.reset!
      @events = nil
    end

    def include?(required_date)
      required_date = Date.parse(required_date) if required_date.is_a?(String)

      if required_date < @options[:starts] || required_date > @options[:until]
        false
      else
        each do |date|
          return true if date == required_date
        end
      end

      return false
    end

    def next
      @event.next
    end

    def next!
      @event.next!
    end

    def events(options={})
      options[:starts] = Date.parse(options[:starts]) if options[:starts].is_a?(String)
      options[:until]  = Date.parse(options[:until])  if options[:until].is_a?(String)

      reset! if options[:starts] || options[:until]

      @events ||= begin
        _events = []

        loop do
          date = @event.next!

          break if date.nil?

          valid_start = options[:starts].nil? || date >= options[:starts]
          valid_until = options[:until].nil?  || date <= options[:until]
          _events << date if valid_start && valid_until

          break if options[:until] && options[:until] <= date
        end

        _events
      end
    end

    def events!(options={})
      reset!
      events(options)
    end

    def each!(&block)
      reset!
      each(&block)
    end

    def each(&block)
      events.each do |item|
        yield item
      end
    end

    private

      def initialize_dates(options) #:nodoc:
        [:starts, :until].each do |name|
          options[name] = Date.parse(options[name]) if options[name].is_a?(String)
        end

        options[:starts] ||= Date.today
        options[:until]  ||= self.class.default_until_date

        options
      end
  end
end
