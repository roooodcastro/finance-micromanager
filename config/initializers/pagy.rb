# frozen_string_literal: true

require 'pagy/extras/metadata'
require 'pagy/extras/overflow'

Pagy::DEFAULT[:items]    = 5
Pagy::DEFAULT[:metadata] = %i[count page items pages from to].freeze
Pagy::DEFAULT[:overflow] = :last_page
