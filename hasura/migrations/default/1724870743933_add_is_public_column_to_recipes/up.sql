SET check_function_bodies = false;
CREATE TABLE public.bookmarks (
    user_id uuid NOT NULL,
    recipe_id uuid NOT NULL
);
CREATE TABLE public.categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);
CREATE TABLE public.comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    recipe_id uuid,
    user_id uuid,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);
CREATE TABLE public.ingredients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);
CREATE TABLE public.likes (
    user_id uuid NOT NULL,
    recipe_id uuid NOT NULL
);
CREATE TABLE public.ratings (
    user_id uuid NOT NULL,
    recipe_id uuid NOT NULL,
    rating integer,
    CONSTRAINT ratings_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);
CREATE TABLE public.recipe_images (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    recipe_id uuid,
    image_url text NOT NULL,
    is_featured boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);
CREATE TABLE public.recipe_ingredients (
    recipe_id uuid NOT NULL,
    ingredient_id uuid NOT NULL,
    quantity character varying(100)
);
CREATE TABLE public.recipes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    preparation_time interval,
    category_id uuid,
    user_id uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    is_public boolean DEFAULT false
);
CREATE TABLE public.steps (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    recipe_id uuid,
    step_number integer NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);
CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    role character varying(50) DEFAULT 'user'::character varying
);
ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (user_id, recipe_id);
ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);
ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (user_id, recipe_id);
ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (user_id, recipe_id);
ALTER TABLE ONLY public.recipe_images
    ADD CONSTRAINT recipe_images_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_pkey PRIMARY KEY (recipe_id, ingredient_id);
ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.steps
    ADD CONSTRAINT steps_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);
CREATE INDEX idx_bookmarks_recipe_id ON public.bookmarks USING btree (recipe_id);
CREATE INDEX idx_bookmarks_user_id ON public.bookmarks USING btree (user_id);
CREATE INDEX idx_comments_recipe_id ON public.comments USING btree (recipe_id);
CREATE INDEX idx_comments_user_id ON public.comments USING btree (user_id);
CREATE INDEX idx_ingredients_name ON public.ingredients USING btree (name);
CREATE INDEX idx_likes_recipe_id ON public.likes USING btree (recipe_id);
CREATE INDEX idx_likes_user_id ON public.likes USING btree (user_id);
CREATE INDEX idx_ratings_recipe_id ON public.ratings USING btree (recipe_id);
CREATE INDEX idx_ratings_user_id ON public.ratings USING btree (user_id);
CREATE INDEX idx_recipe_images_is_featured ON public.recipe_images USING btree (is_featured);
CREATE INDEX idx_recipe_images_recipe_id ON public.recipe_images USING btree (recipe_id);
CREATE INDEX idx_recipe_ingredients_ingredient_id ON public.recipe_ingredients USING btree (ingredient_id);
CREATE INDEX idx_recipe_ingredients_recipe_id ON public.recipe_ingredients USING btree (recipe_id);
CREATE INDEX idx_recipes_category_id ON public.recipes USING btree (category_id);
CREATE INDEX idx_recipes_user_id ON public.recipes USING btree (user_id);
CREATE INDEX idx_steps_recipe_id ON public.steps USING btree (recipe_id);
CREATE INDEX idx_users_email ON public.users USING btree (email);
CREATE INDEX idx_users_username ON public.users USING btree (username);
ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);
ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);
ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);
ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE ONLY public.recipe_images
    ADD CONSTRAINT recipe_images_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);
ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id);
ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);
ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);
ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE ONLY public.steps
    ADD CONSTRAINT steps_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);
