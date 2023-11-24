# frozen_string_literal: true

require 'pagy/extras/metadata'
require 'pagy/extras/overflow'

Pagy::DEFAULT[:items]    = 25
Pagy::DEFAULT[:size]     = [1, 2, 2, 1]
Pagy::DEFAULT[:metadata] = %i[count page items pages from to series].freeze
Pagy::DEFAULT[:overflow] = :last_page
