class JobFetcher < ApplicationRecord
    require 'google_search_results'

    def self.scrape_jobs(job_title, location, remote, language_code, number_of_jobs, fun_bullet_point, board_relevance)
        @q = job_title
        @location = location
        @ltype = get_remote_code(remote)
        @hl = language_code
        @number_of_jobs = number_of_jobs
        @fun_bullet_point = fun_bullet_point
        @board_relevance = board_relevance
        @job_boards_covered = []
        response = get_jobs

        puts "COMPLETED: #{response.length} jobs added to the list.\n\n"

        @job_boards_covered.sort_by! { |job_board| job_board.downcase }
        puts 'Job boards covered:'
        @job_boards_covered.each do |job_board|
          puts job_board
        end
        response
      end

      def self.get_jobs
        response = []
        next_page_token = nil
        current_number_of_jobs = 0
        total_number_of_jobs = 0

        puts 'Starting to scrape jobs'

        while response.length < @number_of_jobs
          current_response = get_page_result(next_page_token: next_page_token)

          break if current_response[:jobs_results].nil?
          total_number_of_jobs += current_response[:jobs_results].length

          current_response[:jobs_results].each do |result|
            break if response.length >= @number_of_jobs

            unless response.any? { |job| job[:title] == result[:title] && job[:company] == result[:company_name] }
              response << {
                title: result[:title],
                company: result[:company_name],
                link: get_url(result)
              }
            end
          end

          unless response.length == current_number_of_jobs
            puts "Scraping... #{response.length} unique jobs out of #{total_number_of_jobs} jobs scraped."
          end

          current_number_of_jobs = response.length
          break if current_response[:serpapi_pagination].nil?
          next_page_token = current_response[:serpapi_pagination][:next_page_token]
        end
        response.sort_by { |job| job[:title].downcase }
      end

      def self.get_page_result(next_page_token: nil)
        search = GoogleSearch.new(request_params(next_page_token: next_page_token))
        search.get_hash
      end

      def self.request_params(next_page_token: nil)
        require 'date'
        start_date = (Date.today - 3).strftime("%m/%d/%Y") # 3 days ago
        end_date = Date.today.strftime("%m/%d/%Y")         # Today
        params = {
          engine: 'google_jobs',          # specify which engine you want to scrape using SerpApi
          q: @q,                          # query you're requestig from the search engine
          hl: @hl,                        # language code for the language you want the results to be
          no_cache: true,                 # specify whether you want cached responses from SerpApi
          api_key: '923b22c626e8cf389a5d5e1d9b418abe5d8dff14a26d9be9e3cea56369eaf309', # SerpApi Secret API Key you need to use SerpApi
          tbs: "qdr:m"
        }


        params.merge!(next_page_token: next_page_token) if next_page_token
        params.merge!(location: @location) if @location
        params.merge!(ltype: @ltype) if @ltype # specify whether you want jobs to be remote or not - you can omit this argument to get both remote and non-remote jobs in the response
        params
      end

      def self.get_url(result)
        sorted_links = sort_links_by_relevance(result[:apply_options])

        uri = URI.parse(sorted_links.first[:link])
        query_params = CGI.parse(uri.query.to_s)      
        filtered_params = query_params.reject { |key| key.start_with?('utm') }
        uri.query = URI.encode_www_form(filtered_params)

        uri.to_s
      end

      def self.board_relevance_normalized
        @board_relevance_normalized ||= @board_relevance.map do |board|
          board.downcase.gsub(/\s+/, '')
        end
      end

      def self.sort_links_by_relevance(apply_options)
        apply_options.sort_by do |option|
          next Float::INFINITY if option[:title].nil?
          @job_boards_covered << option[:title] unless @job_boards_covered.include?(option[:title])

          normalized_title = option[:title].downcase.gsub(/\s+/, '')
          board_relevance_normalized.index(normalized_title) || Float::INFINITY
        end
      end

      def self.get_remote_code(remote)
        case remote
        when true
          1
        when false
          0
        else
          nil
        end
      end
    
end
