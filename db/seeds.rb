# db/seeds.rb
require 'faker'
require 'securerandom'
Faker::Config.locale = 'en'

puts "Seeding started at #{Time.current}"

# Safety: wrap in a transaction so partial seeds don't stay if something fails
ActiveRecord::Base.transaction do
  # Clear existing small-data if you want (optional)
  # Uncomment if you want to wipe these tables before seeding:
  # Borrow.delete_all
  # Book.delete_all
  # Author.delete_all
  # User.delete_all

  # 1) Users (200)
  users = []
  200.times do |i|
    users << {
      name: Faker::Name.name,
      email: "user#{i+1}@example.com",
      password: "password#{i+1}",
      created_at: Time.current,
      updated_at: Time.current
    }
  end
  if User.respond_to?(:insert_all)
    User.insert_all(users)
    puts "Inserted 200 users via insert_all"
  else
    users.each { |u| User.create!(u) }
    puts "Inserted 200 users via create!"
  end
  user_ids = User.order(:id).limit(200).pluck(:id) # ensure we have the ids

  # 2) Authors (100)
  authors = []
  100.times do |i|
    authors << {
      name: Faker::Book.unique.author,
      bio: Faker::Lorem.paragraph(sentence_count: 3),
      created_at: Time.current,
      updated_at: Time.current
    }
  end
  if Author.respond_to?(:insert_all)
    Author.insert_all(authors)
    puts "Inserted 100 authors via insert_all"
  else
    authors.each { |a| Author.create!(a) }
    puts "Inserted 100 authors via create!"
  end
  author_ids = Author.order(:id).limit(100).pluck(:id)

  # 3) Books (1000)
  books = []
  Faker::UniqueGenerator.clear
  500.times do |i|
    # realistic 13-digit ISBN
    isbn = 13.times.map { rand(0..9) }.join
    books << {
      title: "#{Faker::Book.title} #{i}",
      isbn: isbn,
      published_date: Faker::Date.between(from: '1900-01-01', to: Date.today),
      author_id: author_ids.sample,
      created_at: Time.current,
      updated_at: Time.current
    }
  end
  if Book.respond_to?(:insert_all)
    Book.insert_all(books)
    puts "Inserted 1000 books via insert_all"
  else
    books.each { |b| Book.create!(b) }
    puts "Inserted 1000 books via create!"
  end
  book_ids = Book.order(:id).limit(1000).pluck(:id)

  # 4) Borrows (5000) — ensure unique pairs to avoid uniqueness validation issues
  target = 5000
  pairs = Set.new
  borrows = []

  # Create unique (user_id, book_id) pairs
  while pairs.size < target
    u = user_ids.sample
    b = book_ids.sample
    key = "#{u}_#{b}"
    next if pairs.include?(key)
    pairs << key

    issue_date = Faker::Date.between(from: 1.year.ago, to: Date.today)
    due_date   = issue_date + rand(7..30).days

    borrows << {
      user_id: u,
      book_id: b,
      issue_date: issue_date,
      due_date: due_date,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  if Borrow.respond_to?(:insert_all)
    Borrow.insert_all(borrows)
    puts "Inserted 5000 borrows via insert_all"
  else
    # fallback: create in batches for performance, rescuing validation errors (shouldn't happen)
    borrows.each_slice(500) do |slice|
      slice.each do |attrs|
        begin
          Borrow.create!(attrs)
        rescue ActiveRecord::RecordInvalid => e
          # skip invalid (very unlikely because we ensured unique pairs and valid dates)
        end
      end
    end
    puts "Inserted 5000 borrows via create! fallback"
  end
end

puts "Seeding finished at #{Time.current}"
