# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    # 進行中の書籍 (未読・読書中)
    # deadline が NULL のものは default で最後にソートされる
    @reading_books = current_user.books.where(status: [ :unread, :reading ]).order(deadline: :asc)
    @total_daily_quota = @reading_books.sum(&:daily_quota)

    # 最近読了した本
    @recent_completed_books = current_user.books.where(status: :completed).order(completed_at: :desc).limit(3)

    # 読書統計
    @total_books_read = current_user.books.where(status: :completed).count
    @total_pages_read = ReadingLog.joins(:book).where(books: { user_id: current_user.id }).sum(:pages_read)

    # 読書ストリーク計算 (昨日のログ、または今日のログがあればカウント)
    @streak_days = calculate_reading_streak

    # 週次アクティビティ (過去7日間の日別読了ページ数)
    @weekly_activity = calculate_weekly_activity
  end

  private

  def calculate_reading_streak
    dates = ReadingLog.joins(:book)
                      .where(books: { user_id: current_user.id })
                      .order(read_at: :desc)
                      .pluck(:read_at)
                      .uniq
    return 0 if dates.empty?

    # 最新の読書日が今日でも昨日でもない場合、ストリークは0
    latest_read_date = dates.first
    current_date = Date.current
    return 0 if latest_read_date < current_date - 1.day

    streak = 0
    # 基準日は、今日読んでいるなら今日、そうでなければ昨日
    check_date = dates.include?(current_date) ? current_date : current_date - 1.day

    dates.each do |date|
      if date == check_date
        streak += 1
        check_date -= 1.day
      elsif date < check_date
        break
      end
    end
    streak
  end

  def calculate_weekly_activity
    start_date = Date.current - 6.days
    logs = ReadingLog.joins(:book)
                      .where(books: { user_id: current_user.id })
                      .where(read_at: start_date..Date.current)
                      .group(:read_at)
                      .sum(:pages_read)
    (start_date..Date.current).map { |date| [ date, logs[date] || 0 ] }
  end
end
