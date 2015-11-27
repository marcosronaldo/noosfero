class ChangeArticleFollowers < ActiveRecord::Migration
	def up
		Article.find_each do |article|
			followers = article.setting["followers"] || []
			followers.each do |follower|
				u = article.environment.users.where(:email => follower)
				p = u.blank? ? nil : u.first.person
				article.person_followers += p unless p.blank?
			end
			article.setting.except!("followers")
			article.save!
		end
	end

	def down
		say "this migration can't be reverted"
	end
end
