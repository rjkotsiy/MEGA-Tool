# encoding: utf-8

require 'csv'
require 'presenters/abstract_presenter'

module MGT
  class CsvPresenter < AbstractPresenter

    ##
    # fill the output file with incoming data.

    def print info

      backup_output_file @name

      CSV.open("#{@name}.csv", "wb", {headers: true, :col_sep => ";"}) do |csv|
        info.each do |line|
          csv << line
        end
      end
    end


    private

    ##
    # method backup previous output file in case of such exist.

    def backup_output_file filename

      if File.file?("#{filename}.csv")

        file_datetime = File.mtime("#{filename}.csv").strftime("%F_%H-%M-%S")

        backup_filename = "#{filename}-#{file_datetime}"

        File.rename("#{filename}.csv", "#{backup_filename}.csv")

      end

    end
  end
end