defmodule BeExerciseWeb.UserControllerTest do
  use BeExerciseWeb.ConnCase, async: true

  test "GET /users", %{conn: conn} do
    conn = get(conn, ~p"/users")

    assert %{
             "data" => %{
               "users" => _,
               "page_number" => _,
               "page_size" => _,
               "total_entries" => _,
               "total_pages" => _
             }
           } = json_response(conn, 200)
  end

  test "POST /invite-users", %{conn: conn} do
    conn = post(conn, ~p"/invite-users")

    assert %{
             "data" => %{
               "message" =>
                 "Invitations sent. It may take a few minutes for the invitations to be delivered."
             }
           } = json_response(conn, 200)
  end
end
