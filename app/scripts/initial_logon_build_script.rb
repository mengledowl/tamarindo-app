class InitialLogonBuildScript
  # creates a new variant per "SKU" in LogOn
  # aka fake SKU aka style + col + dm + size
  # used for initial loading, probably shouldn't ever be used again

  def call
    response = Logon.client.call(:productgroup)

    style_numbers = response.body[:productgroup_response][:rec][:items][:item].map { |item| item[:style] }

    all_styles = style_numbers.map do |style|
      { style: style, detail: Logon.client.call(:styledetail, message: { style: style }) }
    end

    all_styles.map do |style|
      style[:detail].body[:styledetail_response][:rec][:item].map do |item|
        Variant.new.tap do |variant|
          variant.logon_style = style[:style]
          variant.logon_col   = item[:col]
          variant.logon_dm    = item[:dm]
          variant.logon_size  = item[:size]
        end
      end
    end.flatten
  end
end