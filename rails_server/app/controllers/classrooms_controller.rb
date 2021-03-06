class ClassroomsController < ApplicationController
  before_action :signed_in_user

  def index
    current_session = Tyto.db.get_session(session[:app_session_id].to_i)
    if current_session.student_id
      @classrooms = Tyto.db.get_classrooms_for_student(current_session.student_id)
    else
      @classrooms = Tyto.db.get_classrooms_for_teacher(current_session.teacher_id)
    end
    render json: @classrooms
  end

  def students
    students = Tyto.db.get_students_in_classroom(params[:classroom_id]).map{|student|student.email}
    render json: students
  end

  def create
    if params[:id] == nil
    params[:course_id] = Tyto.db.get_course_from_name(params[:course_name]).id
    classroom = Tyto.db.create_classroom(classroom_params)
    params[:classroom_id] = classroom.id
    @invites = Tyto::AddStudentsToClass.run(params).invites
    else
      current = Tyto.db.get_students_in_classroom(params[:id])
      edited = params[:students]
      to_delete = []
      to_add = []
      current.each do |existing|
        matched = false
        edited.each do |recent|
          if existing.email == recent
             matched = true
          end
        end
        to_delete.push(existing) if matched==false
      end

      edited.each do |recent|
        matched = false
        current.each do |existing|
          if existing.email == recent
            matched = true
          end
        end
        to_add.push(recent) if matched==false
      end

      if to_delete != []
        to_delete.each do |student|
          Tyto.db.delete_student_from_classroom(student.id, params[:id])
        end
      end
      if to_add != []
        params[:students] = edited
        params[:classroom_id] = params[:id]
        @invites = Tyto::AddStudentsToClass.run(params).invites
      end
    end
    render json: @invites
  end

  def update
    params[:session_id] = session[:app_session_id]
    #NEED TO COME IN WITH AN ARRAY OF STUDENTS FROM TEACHER DASHBOARD#
    params[:students] = [params[:student_one], params[:student_two]]
    result = Tyto::AddStudentsToClass.run(students_params)
    if result.success?
        result.invite_ids.each do |invite_id|
          email = StudentMailer.classroom_invite(invite_id, result.classroom.id)
          email.deliver
        end
    end
    render json: result
  end

  def update_text
    student = Tyto.db.update_student_in_classroom(params[:student_id], params[:classroom_id], params[:text])
    render json: student
  end

  def accepted
    classrooms = Tyto.db.get_classrooms_for_student(params[:student_id].to_i)
    classroom_ids = classrooms.map{|classroom| classroom.id}
    chats = []
    classroom_ids.each do |id|
      classroom = Tyto.db.get_classroom(id)
      chat = Tyto.db.get_past_messages(id, 30)
      chats.push({name: classroom.name, id: classroom.id, chat: chat})
    end
    render json: chats
  end

  private

  def classroom_params
    params.permit(:name,
                  :course_id,
                  :teacher_id)
  end

  def add_students_params
    params.permit(:teacher_id, :classroom_id, :students)

  end

  def students_params
    params.permit(:classroom_id,
                  :session_id,
                  :students,
                  :student_one,
                  :student_two)
  end

  def signed_in_user
    redirect_to "/signin", notice: "Please sign in." unless !!session[:app_session_id]
  end
end
