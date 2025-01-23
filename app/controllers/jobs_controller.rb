class JobsController < ApplicationController

    def job_search
        job_title = 'Ruby on Rails'
        location = 'United States'
        remote = true
        language_code = 'en'
        number_of_jobs = 100
        board_relevance = [
        'LinkedIn',
        'Indeed',
        'Glassdoor',
        'Monster',
        'Upwork',
        'GoRails Jobs',
        'Ruby On Remote',
        'We Are Hiring',
        'We Work Remotely'
        ]
        @fun_bullet_point = '🦖'


        search_params = { job_title: job_title }
        search_params.merge!(location: location) if defined?(location)
        search_params.merge!(remote: remote) if defined?(remote)
        search_params.merge!(language_code: language_code) if defined?(language_code)
        search_params.merge!(number_of_jobs: number_of_jobs) if defined?(number_of_jobs)
        search_params.merge!(fun_bullet_point: fun_bullet_point) if defined?(fun_bullet_point)
        search_params.merge!(board_relevance: board_relevance) if defined?(board_relevance)
        @api_response = JobFetcher.scrape_jobs(job_title, location, remote, language_code, number_of_jobs, @fun_bullet_point, board_relevance)
    end

end
