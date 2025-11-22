-- Create votes table if it doesn't exist
CREATE TABLE IF NOT EXISTS votes (
    id VARCHAR(255) NOT NULL UNIQUE,
    vote VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_votes_id ON votes(id);

-- Grant permissions
GRANT ALL PRIVILEGES ON TABLE votes TO postgres;
