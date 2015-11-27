class ChangeArticleFollowers < ActiveRecord::Migration
  def up
    page = 1
    articles_page = Article.where({}).page(i=page).per_page(10)

    while !articles_page.blank? do
      articles_page.each do |article|
        break if article.nil?
        followers = article.setting["followers"] || []
        followers.each do |follower|
          u = User.where(:email => follower)
          p = u.blank? ? nil : u.first.person
          article.person_followers += p unless p.blank?
          article.setting.except!("followers")
          article.save!
        end
        articles_page = Article.where({}).page(page).per_page(10)
        page += 10
      end
    end
  end

  def down
    say "this migration can't be reverted"
  end
end
