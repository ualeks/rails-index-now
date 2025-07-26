# frozen_string_literal: true

module Rails
  module Index
    module Now
      class SubmitJob < ActiveJob::Base
        queue_as :default

        def perform(urls)
          Client.new.submit(urls)
        end
      end
    end
  end
end
