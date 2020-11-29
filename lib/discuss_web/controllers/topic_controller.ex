defmodule DiscussWeb.TopicController do
    use DiscussWeb, :controller

    alias Discuss.Topic
  
    def new(conn, _params) do
        changeset = Topic.changeset(%Topic{} , %{}) 

        render conn, "new.html", changeset: changeset
    end

    def create(con, _params) do

        
    end
  end
  