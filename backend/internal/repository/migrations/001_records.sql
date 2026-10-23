CREATE TABLE records (
    collection TEXT NOT NULL,
    id TEXT NOT NULL,
    data JSONB NOT NULL CHECK (jsonb_typeof(data) = 'object'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (collection, id)
);
