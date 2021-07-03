option explicit
mode 1,8

dim integer xpos=400, ypos=400 ' player positien
dim integer xmax, xmin ' invader x-bounds
dim float xoff=0, yoff=0, dx=1 'x-pos invaders
dim integer shooter = 0 ' spacebar shoot latch
dim integer q_action = 0 ' Q-key latch
dim integer missile_mode = 0, state = 0, state_counter
dim integer game_over = 0

'dim float ang, vel

'invaders numbers and stuff
dim integer invader_on(120), invader_counter = 0, invader_ix(120), invader_grid(15,8)

'missiles
dim float missile_x(500), missile_y(500)
dim float missile_dx(500), missile_dy(500)
dim integer missile_on(500), missile_next=0, missile_counter = 0, missile_ix(500)

'bombs
dim float bomb_x(50), bomb_y(50)
dim float bomb_dx(50), bomb_dy(50)
dim integer bomb_on(50), bomb_next=0, bomb_counter = 0, bomb_ix(50)

'sound
dim tones(16)

page write 0
sprite close all
cls
box 0,10,54,10,,rgb(white),rgb(white)
box 22,0,10,10,,rgb(white),rgb(white)
sprite read 64,0,0,54,20


cls
Init_tones
Init_invaders
Calc_bounds

page write 1
do while game_over <> 999
  page copy 1 to 0
  cls
  
  if game_over = 0 then
    Render_invaders
    Render_missiles
    Render_bombs
    if rnd > 0.95 then Drop_bomb
  'sprite write 64,xpos,ypos
    box xpos-3,ypos-3,6,6,,RGB(blue),rgb(blue)
    Handle_keyboard
    Handle_statemachine

  elseif game_over = 1 then
    Render_invaders
    Render_explosion
    if missile_counter = 0 then game_over = 999
  endif
  
loop
end

data 105,113,121,131,143,158,175,197,225,263,315,394,525,629,788,1051


sub Calc_bounds
local x, y, a, f, n

x = xmin
f = 0
do while x < xmax and f = 0
  y = 0
  do while y < 8 and f = 0
    n = x + y * 15
    f = f + invader_on(n)
    y = y + 1
  loop
  if f = 0 then x = x + 1
loop
xmin = x

if xmin < xmax then
  x = xmax
  f = 0
  do while x > xmin and f = 0
    y = 0
    do while y < 8 and f = 0
      n = x + y * 15
      f = f + invader_on(n)
      y = y + 1
    loop
    if f = 0 then x = x - 1
  loop
  xmax = x
endif
end sub

sub Drop_bomb
  local integer a
  
  do while bomb_on(bomb_next)
    bomb_next = (bomb_next+1) mod 50
  loop
  a = rnd * invader_counter
  a = invader_ix(a)
  bomb_x(bomb_next) = (a mod 15) * 40 + 12.5 + xoff
  bomb_y(bomb_next) = (a \ 15) * 40 + 30 + yoff
  bomb_dx(bomb_next) = 0
  bomb_dy(bomb_next) = 2 + rnd * 3
  bomb_on(bomb_next) = 1
  bomb_ix(bomb_counter) = bomb_next
  bomb_next = (bomb_next+1) mod 50
  bomb_counter = bomb_counter + 1
end sub

sub Player_explode
  local integer b
  local float ang, vel
  
  for b = 0 to 299
    missile_x(b) = xpos
    missile_y(b) = ypos
    vel = 1 + rnd * 5
    ang = rnd * 3.14
    missile_dx(b) = vel * cos(ang)
    missile_dy(b) = -vel * sin(ang)
    missile_on(b) = 1
    missile_ix(b) = b
  next b
  missile_counter = 300
end sub

sub Render_explosion
  local integer a,b,c,d,x,y,xm,ym,xp,yp
  local note%
  
  b=0
  c=0
  do while c < missile_counter
    a = missile_ix(c)
    box missile_x(a), missile_y(a),5,5,,rgb(white), rgb(white)
    missile_x(a) = missile_x(a) + missile_dx(a)
    missile_y(a) = missile_y(a) + missile_dy(a)
    missile_dy(a) = missile_dy(a) + 0.05
    xp = missile_x(a) - xoff
    yp = missile_y(a) - yoff
    x = xp\40
    xm = xp mod 40
    y = yp\40
    ym = yp mod 40
    if x >= 0 and x < 15 and xm < 30 and y >= 0 and y < 8 and ym < 30 then
      d = x + 15 * y
      if invader_on(d) then
        invader_on(d) = 0
        missile_x(a) = -1
        if timer>5000 then
          note% = rnd * bound(tones())
          play tone tones(note%), tones(note%), 50
        endif
      endif
    endif
    if missile_x(a) < 0 or missile_y(a) < 0 or missile_x(a) > 799 or missile_y(a) > 599 then
      missile_on(a) = 0
    else
      missile_ix(b) = a
      b = b + 1
    endif
    c = c + 1
  loop
  missile_counter = b
end sub

sub Render_invaders
  local integer a, b, c, x, y

  b=0
  c=0
  do while b < invader_counter
    a = invader_ix(b)
    y = (a\15)*40
    x = (a mod 15) * 40
    if invader_on(a) then
      box x+xoff,y+yoff,30,30,,RGB(red),rgb(red)
      invader_ix(c) = a
      c = c + 1
    endif
    b = b + 1
  loop
  invader_counter = c
end sub

sub Render_missiles
  local integer a,b,c,d,x,y,xm,ym,xp,yp
  local note%
  
  b=0
  c=0
  do while c < missile_counter
    a = missile_ix(c)
    box missile_x(a), missile_y(a),5,5,,rgb(green), rgb(green)
    missile_x(a) = missile_x(a) + missile_dx(a)
    missile_y(a) = missile_y(a) + missile_dy(a)
    xp = missile_x(a) - xoff
    yp = missile_y(a) - yoff
    x = xp\40
    xm = xp mod 40
    y = yp\40
    ym = yp mod 40
    if x >= 0 and x < 15 and xm < 30 and y >= 0 and y < 8 and ym < 30 then
      d = x + 15 * y
      if invader_on(d) then
        invader_on(d) = 0
        Calc_bounds
        missile_x(a) = -1
        note% = rnd * bound(tones())
        play tone tones(note%), tones(note%), 50
      endif
    endif
    if missile_x(a) < 0 or missile_y(a) < 0 or missile_x(a) > 799 or missile_y(a) > 599 then
      missile_on(a) = 0
    else
      missile_ix(b) = a
      b = b + 1
    endif
    c = c + 1
  loop
  missile_counter = b
end sub

sub Render_bombs
  local integer a,b,c,x,y

  b=0
  c=0
  do while c < bomb_counter
    a = bomb_ix(c)
    box bomb_x(a), bomb_y(a),5,5,,rgb(yellow), rgb(yellow)
    bomb_x(a) = bomb_x(a) + bomb_dx(a)
    bomb_y(a) = bomb_y(a) + bomb_dy(a)
    x = bomb_x(a) - xpos
    y = bomb_y(a) - ypos
    if x >= 0 and x < 15 and y >= 0 and y < 15 and game_over = 0 then
      bomb_x(a) = -1
      game_over = game_over + 1
      Player_explode 
      play wav "A:/Invaders/explode.wav"
      timer = 0
'      play tone 1000, 1000, 500
    endif
    if bomb_x(a) < 0 or bomb_y(a) < 0 or bomb_x(a) > 799 or bomb_y(a) > 599 then
      bomb_on(a) = 0
    else
      bomb_ix(b) = a
      b = b + 1
    endif
    c = c + 1
  loop
  bomb_counter = b

end sub  

sub Handle_keyboard
  local integer a,s, l, xa, xb, space_pressed, q_pressed
  local float ang, vel
  
  space_pressed = 0
  q_pressed = 0
  s=keydown(0)
  for l=1 to s
    xa = xoff + (xmin*40)
    xb = xoff + 30 + (xmax*40)
'    text 700,0,"Key:" + str$(keydown(l))
    if keydown(l)=130 and xpos > -53 then
      xpos=xpos-1
    elseif keydown(l)=131 and xpos < 800 then
      xpos=xpos+1
    elseif keydown(l)=128 and ypos > 0 then
      ypos=ypos-1
    elseif keydown(l)=129 and ypos < 580 then
      ypos=ypos+1
    elseif keydown(l)=132 and xa > 0 then
      xoff = xoff-1
    elseif keydown(l)=134 and xb < 799 then
      xoff=xoff+1
    elseif keydown(l)=136 then
      yoff=yoff-1
    elseif keydown(l)=137 then
      yoff=yoff+1
    elseif keydown(l)=32 then
      space_pressed = 1
    elseif keydown(l)=113 then
      q_pressed = 1
    endif
  next l
  
  if q_pressed and not q_action then
    missile_mode = (missile_mode + 1) mod 2
    q_action = 1
  else if not q_pressed then
    q_action = 0
  endif
  
  if space_pressed and shooter = 0 then
    select case missile_mode
      case 0
        do while missile_on(missile_next)
          missile_next = (missile_next+1) mod 50
        loop
        missile_x(missile_next) = xpos-2.5
        missile_y(missile_next) = ypos
        missile_dx(missile_next) = 0
        missile_dy(missile_next) = -3
        missile_on(missile_next) = 1
        missile_ix(missile_counter) = missile_next
        missile_next = (missile_next+1) mod 50
        missile_counter = missile_counter + 1
        play tone 600, 600, 20
        shooter = 1
      case 1
        for a = 0 to 10
          do while missile_on(missile_next)
            missile_next = (missile_next+1) mod 50
          loop
          ang = 0.25 - rnd * 0.5
          vel = -3 - rnd * 3
          missile_x(missile_next) = xpos-2.5
          missile_y(missile_next) = ypos
          missile_dx(missile_next) = vel * sin(ang)
          missile_dy(missile_next) = vel * cos(ang)
          missile_on(missile_next) = 1
          missile_ix(missile_counter) = missile_next
          missile_next = (missile_next+1) mod 50
          missile_counter = missile_counter + 1
        next a
        play tone 760, 760, 20
        shooter = 1
    end select
  endif

  select case missile_mode
    case 0
      if not space_pressed then shooter = 0
    case 1
      if not missile_counter then shooter = 0
  end select

end sub

sub Init_invaders
  local integer a,x,y
  
  for a=0 to 119
    if rnd > 0.5 then
      invader_on(a) = 1
      invader_ix(invader_counter) = a
      y = (a\15)
      x = (a mod 15)
      invader_grid(x,y) = 1
      invader_counter = invader_counter + 1
    endif
  next a
  xmin = 0
  xmax = 14
end sub

sub Init_tones
  local i
  
  for i=0 to bound(tones())-1
    read tones(i)
  next i
end sub

sub Handle_statemachine
  local integer xa
  
  select case state
    case 0
      xoff = xoff + dx
      xa = xoff + 30 + xmax * 40
      if xa >= 799 then
        state = 1
        state_counter = 10
      endif
    case 1
      yoff = yoff + 0.5
      state_counter = state_counter - 1
      if state_counter = 0 then state = 2
    case 2
      xoff = xoff - dx
      xa = xoff + xmin * 40
      if xa <= 0 then
        state = 3
        state_counter = 10
      endif
    case 3
      yoff = yoff + 0.5
      state_counter = state_counter - 1
      if state_counter = 0 then state = 0
  end select
end sub
