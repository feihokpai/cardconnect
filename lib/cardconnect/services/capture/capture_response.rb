module CardConnect
  module Service
    class CaptureResponse
      include Utils

      FIELDS = [:merchid, :account, :amount, :retref, :setlstat, :respproc,
                :resptext, :commcard, :respstat, :respcode,
                :batchid, :token].freeze

      # Settlement Statuses
      TXN_NOT_FOUND = 'Txn not found' # The Retref was not found
      AUTHORIZED    = 'Authorized' # Auth only, not captured
      QUEUED        = 'Queued for Capture' # Queued for the Processor
      ZERO_AMOUNT   = 'Zero Amount' # Capture (and Auth) were Voided
      ACCEPTED      = 'Accepted' # Accepted by the Processor
      REJECTED      = 'Rejected' # Rejected by the Processor

      # Response Status
      STATUS_RETRY    = 'B'.freeze
      STATUS_DECLINED = 'C'.freeze

      attr_accessor(*FIELDS)
      attr_reader :errors

      def initialize(response)
        set_attributes(response, FIELDS)
        @errors = []
        process_errors
      end

      def success?
        @errors.empty?
      end

      def body
        FIELDS.collect{|attr| {attr => send(attr)} }.reduce({}, :merge)
      end

      private

      def process_errors
        @errors << resptext if [STATUS_RETRY, STATUS_DECLINED].include?(respstat)
      end
    end
  end
end
