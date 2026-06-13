# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Genres", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "POST /mypage/genres" do
    context "未ログインの場合" do
      it "ログイン画面へリダイレクトされる" do
        post mypage_genres_path, params: { genre: { name: "SF" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      context "有効なジャンル名の場合" do
        it "ジャンルが作成される" do
          expect {
            post mypage_genres_path, params: { genre: { name: "SF" } }
          }.to change(Genre, :count).by(1)
        end

        it "自分のジャンルとして作成される" do
          post mypage_genres_path, params: { genre: { name: "SF" } }
          expect(user.genres.find_by(name: "SF")).to be_present
        end
      end

      context "ジャンル名が空の場合" do
        it "ジャンルが作成されない" do
          expect {
            post mypage_genres_path, params: { genre: { name: "" } }
          }.not_to change(Genre, :count)
        end

        it "422 を返す" do
          post mypage_genres_path,
               params: { genre: { name: "" } },
               headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "同一ユーザー内で重複するジャンル名の場合" do
        before { create(:genre, user: user, name: "SF") }

        it "ジャンルが作成されない" do
          expect {
            post mypage_genres_path, params: { genre: { name: "SF" } }
          }.not_to change(Genre, :count)
        end
      end
    end
  end

  describe "GET /mypage/genres/:id/edit" do
    let!(:genre) { create(:genre, user: user, name: "SF") }

    context "未ログインの場合" do
      it "ログイン画面へリダイレクトされる" do
        get edit_mypage_genre_path(genre)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "200 OK を返す" do
        get edit_mypage_genre_path(genre)
        expect(response).to have_http_status(:ok)
      end

      context "他ユーザーのジャンルにアクセスした場合" do
        let(:other_genre) { create(:genre, user: other_user, name: "他人のジャンル") }

        it "404 を返す" do
          get edit_mypage_genre_path(other_genre)
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "PATCH /mypage/genres/:id" do
    let!(:genre) { create(:genre, user: user, name: "SF") }

    context "未ログインの場合" do
      it "ログイン画面へリダイレクトされる" do
        patch mypage_genre_path(genre), params: { genre: { name: "ファンタジー" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      context "有効なジャンル名の場合" do
        it "ジャンル名が更新される" do
          patch mypage_genre_path(genre), params: { genre: { name: "ファンタジー" } }
          expect(genre.reload.name).to eq("ファンタジー")
        end
      end

      context "ジャンル名が空の場合" do
        it "ジャンルが更新されない" do
          patch mypage_genre_path(genre), params: { genre: { name: "" } }
          expect(genre.reload.name).to eq("SF")
        end

        it "422 を返す" do
          patch mypage_genre_path(genre),
                params: { genre: { name: "" } },
                headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "他ユーザーのジャンルを更新しようとした場合" do
        let(:other_genre) { create(:genre, user: other_user, name: "他人のジャンル") }

        it "404 を返す" do
          patch mypage_genre_path(other_genre), params: { genre: { name: "変更" } }
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "DELETE /mypage/genres/:id" do
    let!(:genre) { create(:genre, user: user, name: "SF") }

    context "未ログインの場合" do
      it "ログイン画面へリダイレクトされる" do
        delete mypage_genre_path(genre)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "ジャンルが削除される" do
        expect {
          delete mypage_genre_path(genre)
        }.to change(Genre, :count).by(-1)
      end

      context "他ユーザーのジャンルを削除しようとした場合" do
        let(:other_genre) { create(:genre, user: other_user, name: "他人のジャンル") }

        it "404 を返す" do
          delete mypage_genre_path(other_genre)
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
