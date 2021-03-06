require 'rack/test'
require 'rack/test/uploaded_file'

FactoryGirl.define do
  trait :initialize do
    after(:build) do
      g_path = File.expand_path('../utils/wiki.git', __FILE__)
      `test -d #{g_path} || git init --bare #{g_path}`
      GollumRails::Setup.build do |config|
        config.repository = File.expand_path('../utils/wiki.git', __FILE__)
      end
    end
  end
  trait :markdown do
    format :markdown
  end
  trait :mediawiki do
    format :mediawiki
  end
  factory :commit_fakes, class: DefaultCommit do
    sequence :commit do |num|
      { name: "mosny#{num}", message: "message number: #{num}", email: "mosny@zyg.li"}
    end
    initialize_with { attributes }
  end

  trait :default_upload do
    initialize_with { new(attributes) }
    commit { build(:commit_fakes) }
    destination 'uploads'
  end
  factory :blacklist_upload, class: SampleUploadBlacklistPng, traits: [:initialize, :default_upload] do
    file Rack::Test::UploadedFile.new(File.expand_path('../GLD-LOTR-2T.png', __FILE__), "image/png")
  end
  factory :multi_blacklist_upload, class: MultiUploadBlacklistPng, traits: [:initialize, :default_upload] do
    file Rack::Test::UploadedFile.new(File.expand_path('../GLD-LOTR-2T.png', __FILE__), "image/png")
  end
  factory :not_blacklist_upload, class: SampleUploadBlacklistPng, traits: [:initialize, :default_upload] do
    file Rack::Test::UploadedFile.new(File.expand_path('../GLD-LOTR-2T.jpg', __FILE__), "image/jpeg")
  end
  factory :not_whitelist_upload, class: SampleUploadWhitelistPng, traits: [:initialize, :default_upload] do
    file Rack::Test::UploadedFile.new(File.expand_path('../GLD-LOTR-2T.png', __FILE__), "image/png")
  end
  factory :whitelist_upload, class: SampleUploadWhitelistPng, traits: [:initialize, :default_upload] do
    file Rack::Test::UploadedFile.new(File.expand_path('../GLD-LOTR-2T.jpg', __FILE__), "image/jpeg")
  end
  factory :restrictions_upload, class: SampleClassDefinitions, traits: [:initialize, :default_upload] do
    file Rack::Test::UploadedFile.new(File.expand_path('../GLD-LOTR-2T.jpg', __FILE__), "image/jpeg")
  end
  factory :upload, class: GollumRails::Upload, traits: [:initialize, :default_upload] do
    file Rack::Test::UploadedFile.new(File.expand_path('../GLD-LOTR-2T.jpg', __FILE__), "image/jpeg")
  end
  #factory :commit_fakes, class: DefaultCommit do
  #end
  factory :gollum_page_spec, traits: [:initialize, :markdown] do
    name "Goole"
    content "content data. content data. content data."
    commit { {name: "mosny", message: "commit message", email: "mosny@zyg.li"} }
    initialize_with { GollumPageSpec.new(attributes) }
  end
  factory :other_committer, class: GollumPageSpec, traits: [:initialize, :markdown] do
    name "Google"
    content "content data. content data. content data."
    commit { {name: "flo", message: "other commit message", email: "info@zyg.li"} }
    initialize_with { GollumPageSpec.new(attributes) }
  end
end
