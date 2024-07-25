# frozen_string_literal: true

require 'pagy/extras/metadata'
require 'pagy/extras/overflow'

Pagy::DEFAULT[:limit]    = 25
Pagy::DEFAULT[:size]     = 5
Pagy::DEFAULT[:metadata] = %i[count page limit pages from to series].freeze
Pagy::DEFAULT[:overflow] = :last_page
