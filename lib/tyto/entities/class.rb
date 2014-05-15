module Tyto
  class Classroom < Entity
    attr_reader :id, :teacher_id, :course_id, :students, :name, :assignments
    validates_presence_of :teacher_id, :course_id, :name
  end
end
