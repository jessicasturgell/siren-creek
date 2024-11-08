require 'lib/input.rb'

def tick args
  # initialize to title scene
  args.state.current_scene ||= :title_scene
  # capture the title scene to verify it doesn't change through the duration of a tick
  current_scene = args.state.current_scene

  # tick current scene
  case current_scene
  when :title_scene
    tick_title_scene args
  when :menu_scene
    tick_menu_scene args
  when :game_scene
    tick_game_scene args
  when :input_name_scene
    tick_input_name_scene args
  when :greeting_scene
    tick_greeting_scene args
  end

  # ensure current_scene flag isn't set mid tick
  if args.state.current_scene != current_scene
    raise "Scene was changed incorrectly. Set args.state.next_scene to change scenes."
  end

  # if next scene was set, transition current scene to next
  if args.state.next_scene
    args.state.current_scene = args.state.next_scene
    args.state.next_scene = nil
  end
end

def tick_title_scene args
  args.outputs.labels << [640, 525, 'Welcome to', 5, 1]
  args.outputs.labels << [640, 480, 'Siren Creek', 12, 1]
  args.outputs.labels << [640, 100, 'click to start', 1, 1]
  
  if args.inputs.mouse.click
    args.state.next_scene = :menu_scene
  end
end

def tick_menu_scene args
  args.outputs.labels << [640, 525, 'Main Menu', 5, 1]
  args.outputs.labels << [640, 460, '[1] New Game', 1, 1]
  args.outputs.labels << [640, 430, '[2] Back to Title', 1, 1]
  
  if args.inputs.keyboard.key_down.one
    args.state.next_scene = :game_scene
  end

  if args.inputs.keyboard.key_down.two
    args.state.next_scene = :title_scene
  end

  if args.inputs.keyboard.key_down.escape
    args.state.next_scene = :title_scene
  end
end

def tick_game_scene args
  args.outputs.labels << [640, 525, 'Welcome to', 5, 1]
  args.outputs.labels << [640, 480, 'Siren Creek', 12, 1]
  args.outputs.solids << {
    x: 20,
    y: 20,
    w: 1240,
    h: 100,
    r: 0,
    g: 0,
    b: 0
  }
  args.outputs.labels << [40, 100, 'Oh! Hello there...', 1, 0, 255, 255, 255]
  args.outputs.labels << [40, 70, 'You must have been traveling for a very long time to get here! What\'s your name?', 1, 0, 255, 255, 255]
  args.outputs.labels << [1060, 55, '[click to continue]', 0, 0, 255, 255, 255]

  if args.inputs.keyboard.key_down.escape
    args.state.next_scene = :title_scene
  end
  if args.inputs.mouse.click
    args.state.next_scene = :input_name_scene
  end
end

def tick_input_name_scene args
  # Create an input
  args.state.input ||= Input::Text.new(x: 100, y: 600, w: 300, focussed: true)

  # Allow the input to process inputs and render text (render_target)
  args.state.input.tick

  # Get the value
  args.state.input_value = args.state.input.value

  # Output the input
  args.outputs.primitives << args.state.input

  # Output the value
  args.outputs.debug << { x: 100, y: 100, text: "Player Name: #{args.state.input_value}" }.label!

  args.outputs.labels << [1005, 55, '[click enter to confirm]', 0, 0]

  if args.inputs.keyboard.key_down.enter
    args.state.player = args.state.input_value
    args.state.next_scene = :greeting_scene
  end

  if args.inputs.keyboard.key_down.escape
    args.state.next_scene = :title_scene
  end
end

def tick_greeting_scene args
  args.outputs.labels << [40, 100, "So your name is #{args.state.player}? Excellent!", 1, 0, 255, 255, 255]
  args.outputs.solids << {
    x: 20,
    y: 20,
    w: 1240,
    h: 100,
    r: 0,
    g: 0,
    b: 0
  }

  if args.inputs.keyboard.key_down.escape
    args.state.next_scene = :title_scene
  end
end