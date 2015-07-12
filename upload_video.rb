#!/usr/bin/ruby

require "dotenv"
Dotenv.load(*Dir["./.env*.local"])

require 'googleauth'
require 'google/apis/youtube_v3'

# had to add "type": "authenticated_user" to this:
class Uploader
  attr_reader :file, :title, :description, :category_id, :keywords, :privacy_status, :content_type

  def initialize(file:, title: "Test title", description: "Test Description", category_id: 28, keywords: "", privacy_status: "private", content_type: "video/mp4")
    @file           = file
    @title          = title
    @description    = description
    @category_id    = category_id
    @keywords       = keywords
    @privacy_status = privacy_status
    @content_type   = content_type
  end

  def get_authenticated_service
    auth = Google::Apis::YoutubeV3::AUTH_YOUTUBE

    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.authorization = Google::Auth.get_application_default([auth])

    youtube
  end

  def upload
    youtube = get_authenticated_service

    body = {
      snippet: {
        title:          title,
        description:    description,
        tags:           keywords.split(','),
        categoryId:     category_id,
      },
      status: {
        privacyStatus:  privacy_status
      }
    }

    youtube.insert_video(body, upload_source: file, content_type: content_type, part: body.keys.join(','))
    # insert_video(video_object = nil,
    #              auto_levels: nil,
    #              notify_subscribers: nil,
    #              on_behalf_of_content_owner: nil,
    #              on_behalf_of_content_owner_channel: nil,
    #              part: nil,
    #              stabilize: nil,
    #              fields: nil,
    #              quota_user: nil,
    #              user_ip: nil,
    #              upload_source: nil,
    #              content_type: nil,
    #              options: nil,
    #              &block)

  end
end

Uploader.new(file: 'cat_jump.mp4').upload
