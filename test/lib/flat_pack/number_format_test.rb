# frozen_string_literal: true

require "test_helper"
require "json"
require "open3"

module FlatPack
  module Number
    class FormatTest < ActiveSupport::TestCase
      NODE = <<~JS
        let raw = ""
        process.stdin.on("data", (chunk) => { raw += chunk })
        process.stdin.on("end", () => {
          const samples = JSON.parse(raw)
          const formatted = samples.map((sample) => {
            const options = {}
            if (sample.format === "currency") {
              options.style = "currency"
              options.currency = sample.currency
            } else if (sample.format === "percent") {
              options.style = "percent"
            } else if (sample.format === "compact") {
              options.notation = "compact"
            }
            if (sample.decimals != null) {
              options.minimumFractionDigits = sample.decimals
              options.maximumFractionDigits = sample.decimals
            }
            return new Intl.NumberFormat("en", options).format(Number(sample.value))
          })
          process.stdout.write(JSON.stringify(formatted))
        })
      JS

      SAMPLES = [
        {value: "1240", format: "number"},
        {value: "1240.5", format: "number"},
        {value: "1240.5678", format: "number"},
        {value: "-1240.5", format: "number"},
        {value: "0", format: "number"},
        {value: "0.004", format: "number"},
        {value: "1240", format: "number", decimals: 2},
        {value: "1240", format: "currency", currency: "USD"},
        {value: "-1240", format: "currency", currency: "USD"},
        {value: "1240.5", format: "currency", currency: "USD"},
        {value: "1240", format: "currency", currency: "EUR"},
        {value: "1240", format: "currency", currency: "GBP"},
        {value: "1240", format: "currency", currency: "JPY"},
        {value: "1240", format: "currency", currency: "KRW"},
        {value: "1240", format: "currency", currency: "VND"},
        {value: "1240", format: "currency", currency: "CNY"},
        {value: "1240", format: "currency", currency: "CHF"},
        {value: "1240", format: "currency", currency: "AUD"},
        {value: "0.18", format: "percent"},
        {value: "0.186", format: "percent"},
        {value: "-0.18", format: "percent"},
        {value: "0.186", format: "percent", decimals: 1},
        {value: "1", format: "percent"},
        {value: "999", format: "compact"},
        {value: "999.4", format: "compact"},
        {value: "999.5", format: "compact"},
        {value: "1000", format: "compact"},
        {value: "1100", format: "compact"},
        {value: "1150", format: "compact"},
        {value: "1499", format: "compact"},
        {value: "10400", format: "compact"},
        {value: "10500", format: "compact"},
        {value: "100500", format: "compact"},
        {value: "999499", format: "compact"},
        {value: "999500", format: "compact"},
        {value: "999999", format: "compact"},
        {value: "12000", format: "compact"},
        {value: "12000", format: "compact", decimals: 1},
        {value: "12500", format: "compact", decimals: 1},
        {value: "1250000", format: "compact"},
        {value: "1250000000", format: "compact"},
        {value: "1250000000000", format: "compact"},
        {value: "1000000000000000", format: "compact"},
        {value: "10000000000000000", format: "compact"},
        {value: "-1499", format: "compact"},
        {value: "10.4", format: "compact"},
        {value: "10.5", format: "compact"}
      ].freeze

      test "english formatting matches Intl.NumberFormat" do
        stdout, status = Open3.capture2("node", "--input-type=module", "-e", NODE, stdin_data: JSON.generate(SAMPLES))

        assert status.success?, stdout
        JSON.parse(stdout).each_with_index do |expected, index|
          sample = SAMPLES[index]
          got = Format.new(
            sample[:value],
            format: sample[:format],
            currency: sample[:currency],
            decimals: sample[:decimals]
          ).body

          assert_equal expected, got, sample.inspect
        end
      end

      test "prefix and suffix sit outside the formatted number" do
        assert_equal "About 12 left", Format.text(12, prefix: "About ", suffix: " left")
      end
    end
  end
end
