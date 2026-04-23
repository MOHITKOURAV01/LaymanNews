-- Create the saved_articles table
CREATE TABLE saved_articles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  article_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  source_url TEXT,
  source_name TEXT,
  published_at TEXT,
  content TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, article_id)
);

-- Enable Row Level Security
ALTER TABLE saved_articles ENABLE ROW LEVEL SECURITY;

-- Enable Realtime for the table
ALTER PUBLICATION supabase_realtime ADD TABLE saved_articles;

-- Policies

-- Users can only read their own saved articles
CREATE POLICY "Users can view own saved articles" ON saved_articles
  FOR SELECT USING (auth.uid() = user_id);

-- Users can only insert their own saved articles
CREATE POLICY "Users can insert own saved articles" ON saved_articles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own saved articles
CREATE POLICY "Users can delete own saved articles" ON saved_articles
  FOR DELETE USING (auth.uid() = user_id);
