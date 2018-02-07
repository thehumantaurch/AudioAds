episodes = [
	{ id: "paj-103", audio: "++++[MID]+++++[MID]++++[MID]++[POST]" },
	{ id: "efa-931", audio: "[PRE][PRE]++++++++++" },
	{ id: "hab-812", audio: "[PRE][PRE]++++[MID]++++[MID]++[MID]++[POST]" },
	{ id: "abc-123", audio: "[PRE]++++[MID]++++[MID]++[MID]++[POST]" },
	{ id: "dag-892", audio: "++++[MID]++++[MID]++++[POST]" }
]

campaigns = [
	[
		{ audio: "*AcmeA*", type: "PRE", targets: ["dag-892", "hab-812"], revenue: 1 },
		{ audio: "*AcmeB*", type: "MID", targets: ["dag-892", "hab-812"], revenue: 4 },
		{ audio: "*AcmeC*", type: "MID", targets: ["dag-892", "hab-812"], revenue: 5 }
	],
	[
		{ audio: "*TacoCat*", type: "MID", targets: ["abc-123", "dag-892"], revenue: 3 }
	],
	[
		{ audio: "*CorpCorpA*", type: "PRE", targets: ["abc-123", "dag-892"], revenue: 11 },
		{ audio: "*CorpCorpB*", type: "POST", targets: ["abc-123", "dag-892"], revenue: 7 },
	],
	[
		{ audio: "*FurryDogA*", type: "PRE", targets: ["dag-892", "hab-812", "efa-931"], revenue: 11 },
		{ audio: "*FurryDogB*", type: "PRE", targets: ["dag-892", "hab-812", "efa-931"], revenue: 7 },
	],
	[
		{ audio: "*GiantGiraffeA*", type: "MID", targets: ["paj-103", "abc-123"], revenue: 9 },
		{ audio: "*GiantGiraffeB*", type: "MID", targets: ["paj-103", "abc-123"], revenue: 4 },
	]
]

class Ad
	attr_reader :audio, :type, :targets, :revenue

	def initialize(file)
		@audio = file[:audio]
		@type = file[:type]
		@targets = file[:targets]
		@revenue = file[:revenue]
	end

end

class Campaign
	attr_reader :ads, :needed_types, :revenue

	def initialize(ads)
		@ads = ads
		@needed_types = []
		@revenue = campaign_revenue
		campaign_needed_types
	end
	
	def campaign_needed_types
		@ads.each do |ad|
			@needed_types << ad.type
		end
	end
	
	def campaign_revenue
		rev_vals = []
		@ads.each do |ad|
			rev_vals << ad.revenue
		end
		rev_vals.reduce(:+)
	end

end

class EpisodeFile
	attr_accessor :audio, :episode_types_needed
	
	def initialize(file)
		@audio = file[:audio]
		@id = file[:id]
		@episode_types_needed = { "PRE" => 0, "MID" => 0, "POST" => 0 }
		get_episode_types
	end

	def episode_ad_needs
		@audio.gsub("+", "").split("]")
	end

	def get_episode_types
		episode_ad_needs.each do |ad_type|
			ad_type = ad_type.slice(1..-1)
			@episode_types_needed[ad_type] += 1
		end
	end

	def available_campaigns(campaigns)
		avail_campaigns = campaigns.select do |c| 
			c.ads[0].targets.include?(@id)
		end
		avail_campaigns.sort_by! {|c| c.revenue}
		return avail_campaigns.reverse!
	end

	def campaign_ads_fit?(campaign_needed_types, episode_needed_types)
		testing_arr = campaign_needed_types.dup
		testing_hash = episode_needed_types.dup
		testing_arr.each do |type|
			testing_hash[type] -= 1
		end
		if testing_hash.values.min < 0
			return false
		else
			return true
		end
	end

	def choose_ads(campaigns)
		episode_hash = @episode_types_needed
		insertable = available_campaigns(campaigns)
		chosen = []

		insertable.each do |campaign|
			if campaign_ads_fit?(campaign.needed_types, episode_hash)
				campaign.needed_types.each do |type|
					episode_hash[type] -= 1
				end
				chosen << campaign
			end
		end
		return chosen
	end

	def insert_ads(campaigns)
		ads = []
		campaigns = choose_ads(campaigns)
		campaigns.each do |campaign|
			campaign.ads.each do |ad| 
				ads << ad
			end
		end

		ads.each do |ad|
			@audio = @audio.sub("[#{ad.type}]", ad.audio)
		end
		@audio.gsub!("[PRE]", "")
		@audio.gsub!("[MID]", "")
		@audio.gsub!("[POST]", "")
		p @audio
	end
end

ad1 = Ad.new(campaigns[0][0])
ad2 = Ad.new(campaigns[0][1])
ad3 = Ad.new(campaigns[0][2])

ad4 = Ad.new(campaigns[1][0])

ad5 = Ad.new(campaigns[2][0])
ad6 = Ad.new(campaigns[2][1])

ad7 = Ad.new(campaigns[3][0])
ad8 = Ad.new(campaigns[3][1])

ad9 = Ad.new(campaigns[4][0])
ad10 = Ad.new(campaigns[4][1])

campaign1 = Campaign.new([ad1, ad2, ad3])
campaign2 = Campaign.new([ad4])
campaign3 = Campaign.new([ad5, ad6])
campaign4 = Campaign.new([ad7, ad8])
campaign5 = Campaign.new([ad9, ad10])

campaigns = [campaign1, campaign2, campaign3, campaign4, campaign5]

e1 = EpisodeFile.new(episodes[0])
e1.insert_ads(campaigns)
e2 = EpisodeFile.new(episodes[1])
e2.insert_ads(campaigns)
e3 = EpisodeFile.new(episodes[2])
e3.insert_ads(campaigns)
e4 = EpisodeFile.new(episodes[3])
e4.insert_ads(campaigns)
e5 = EpisodeFile.new(episodes[4])
e5.insert_ads(campaigns)
