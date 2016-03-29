# coding: utf-8

# Control the things.
class ThingsController < ActionController::Base
  # GET /things
  def index
    @things = ListThings.run!
  end

  # GET /things/1
  def show
    @thing = find_thing!
  end

  # GET /things/new
  def new
    @thing = CreateThing.new
  end

  # GET /things/1/edit
  def edit
    thing = find_thing!
    @thing = UpdateThing.new(thing: thing, name: thing.name)
  end

  # POST /things
  def create
    outcome = CreateThing.run(params.fetch(:thing, {}))

    if outcome.valid?
      redirect_to(outcome.result)
    else
      @thing = outcome
      render(:new)
    end
  end

  # PUT /things/1
  def update
    inputs = params.fetch(:thing, {}).merge(thing: find_thing!)
    outcome = UpdateThing.run(inputs)

    if outcome.valid?
      redirect_to(outcome.result)
    else
      @thing = outcome
      render(:edit)
    end
  end

  # DELETE /things/1
  def destroy
    DestroyThing.run!(thing: find_thing!)
    redirect_to(things_url)
  end

  private

  def find_thing!
    outcome = FindThing.run(params)

    if outcome.valid?
      outcome.result
    else
      raise ActiveRecord::RecordNotFound,
        outcome.errors.full_messages.to_sentence
    end
  end
end
